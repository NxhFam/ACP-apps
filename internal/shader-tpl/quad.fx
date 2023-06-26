/* Template for Lua shaders used by `ui.ExtraCanvas:updateWithShader()` function */

SamplerState samLinear : register(s0) { Filter = LINEAR; AddressU = WRAP; AddressV = WRAP;};
SamplerComparisonState samShadow : register(s1) { Filter = COMPARISON_MIN_MAG_MIP_LINEAR; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; BorderColor = 1; ComparisonFunc = LESS;};
SamplerState samPoint : register(s2) { Filter = POINT; AddressU = WRAP; AddressV = WRAP;};
SamplerState samLinearSimple : register(s5) { Filter = LINEAR; AddressU = WRAP; AddressV = WRAP;};
SamplerState samLinearBorder0 : register(s6) { Filter = MIN_MAG_MIP_LINEAR; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; BorderColor = (float4)0;};
SamplerState samLinearBorder1 : register(s7) { Filter = MIN_MAG_MIP_LINEAR; AddressU = Border; AddressV = Border; AddressW = Border; BorderColor = (float4)1;};
SamplerState samLinearClamp : register(s8) { Filter = MIN_MAG_MIP_LINEAR; AddressU = CLAMP; AddressV = CLAMP; AddressW = CLAMP;};
SamplerState samPointClamp : register(s9) { Filter = POINT; AddressU = CLAMP; AddressV = CLAMP;};
SamplerState samPointBorder0 : register(s10) { Filter = POINT; AddressU = CLAMP; AddressV = CLAMP;};
SamplerState samAnisotropic : register(s11) { Filter = LINEAR; AddressU = WRAP; AddressV = WRAP;};
SamplerState samAnisotropicClamp : register(s12) { Filter = LINEAR; AddressU = CLAMP; AddressV = CLAMP;};

#define TX_SLOT(X) t##X
#define TX_SLOT_REFLECTION_CUBEMAP TX_SLOT(13)  
#define TX_SLOT_SHADOW_ARRAY TX_SLOT(14)
#define TX_SLOT_SHADOW_CLOUDS TX_SLOT(15)
#define TX_SLOT_DYNAMIC_SHADOWS TX_SLOT(16)
#define TX_SLOT_AO TX_SLOT(17)
#define TX_SLOT_DEPTH TX_SLOT(18)
#define TX_SLOT_PREV_FRAME TX_SLOT(19)
#define TX_SLOT_NOISE TX_SLOT(20)
#define TX_SLOT_BDRF TX_SLOT(21)
#define TX_SLOT_SHADOW_COLOR TX_SLOT(22)
#define TX_SLOT_MIRAGE_MASK TX_SLOT(23)

$DEFINES
$TEXTURES

// 32×32 noise texture:
Texture2D txNoise : register(TX_SLOT_NOISE);

// These textures are only available in main pass:
Texture2D<float> txDepth : register(TX_SLOT_DEPTH);
Texture2D txPreviousFrame : register(TX_SLOT_PREV_FRAME);
TextureCube txReflectionCubemap : register(TX_SLOT_REFLECTION_CUBEMAP);

cbuffer cbCamera : register(b0) {
  float4x4 gView;
  float4x4 gProjection;
  float4x4 gViewProjectionInverse;
  float3 gCameraShiftedPosition;
  float gCameraFOVValue;
  float gNearPlane;
  float gFarPlane;
  float2 _pad0C;
}

cbuffer cbLighting : register(b2) {  
  float3 gLightDirection;
  float _pad7;

  float3 gAmbientColor;
  float _pad8;

  float3 gLightColor;
  float _pad9;

  float4 _pad0;
  float4 _pad1;
  float3 _pad2;
  float gFogLinear;

  float gFogBlend;
  float3 gFogColor;

  float4 _pad3;
  float4 _pad4;

  float4 _pad5;
  float3 _pad6;
  uint gUseNewFog;

  float gFogConstantPiece; 
  float gFogBacklitMult;
  float gFogBacklitExp;
  float gFogExp;

  float4 gAdditionalAmbientColor;
  float _pad10;
  
  float3 gAdditionalAmbientDir;
  float _pad11;

  float3 gBaseAmbient;
  float _pad12;

  float3 gSpecularColor;
  float gSunSpecularMult;

  float4 _pad13;
  float4 _pad14;
  float4 _pad15;
  float4 _pad16;

  float3 _pad17;
  float extCloudShadowOpacity;

  float4x4 _pad18;
  float4 _pad19;
  float4 _pad20;

  float3 gSceneOffset;
  float _pad21;

  float4 _pad22;
}

#define gCameraPosition (gCameraShiftedPosition - gSceneOffset)

float linearizeDepth(float depth){
  return 2 * gNearPlane * gFarPlane / (gFarPlane + gNearPlane - (2 * depth - 1) * (gFarPlane - gNearPlane));
}

cbuffer cbData : register(b10) { 
  $VALUES
}

struct PS_IN { 
  float4 PosH : SV_POSITION; 
  float2 Tex : TEXCOORD0; 
  float2 ScreenPos : TEXCOORD1;  // screen pos from 0 to 1 to sample depth map with
  float3 PosC : TEXCOORD2;       // position of given pixel (at far clipping plane) in world coordinates relative to camera
  float Fog : TEXCOORD3;

  float GetDithering(){  // add this value to output sky color or something like that to avoid banding
    return lerp(0.00196, -0.00196, frac(0.25 + dot(PosH.xy, 0.5)));
  }

  float3 GetDepth(){
    return txDepth.SampleLevel(samLinearSimple, ScreenPos, 0);
  }

  float3 GetPosW(){
    return PosC + gCameraPosition;
  }
  
  float CalculateFogValue(bool usePerPixelFog){
    [branch]
    if (usePerPixelFog && gUseNewFog){
      float3 fromCamera = normalize(PosC);
      if (abs(fromCamera.y) < 0.001) fromCamera.y = 0.001;
      float basePart = (1 - exp(-length(PosC) * fromCamera.y / gFogLinear)) / fromCamera.y;
      return gFogBlend * pow(saturate(gFogConstantPiece * basePart), gFogExp);
    }
    return Fog;
  }

  float3 GetFogColor(){
    float3 fromCamera = normalize(PosC);
    float sunAmount = saturate(dot(-fromCamera, gLightDirection));
    return gFogColor + gLightColor.xyz * pow(sunAmount, gFogBacklitExp) * gFogBacklitMult;
  }

  float3 ApplyFog(float3 color, float fogMult = 1, bool usePerPixelFog = false){
    return lerp(color, GetFogColor(), saturate(fogMult * CalculateFogValue(usePerPixelFog)));
  }

  float3 ApplyFog(float color, float fogMult = 1){
    return ApplyFog(color.xxx, fogMult);
  }

  float4 ApplyFog(float4 color, float fogMult = 1){
    return float4(ApplyFog(color.rgb, fogMult), color.a);
  }

  float FogAlphaMultiplier(float alpha, float fogMult = 1, bool usePerPixelFog = false){
    return saturate(1 - fogMult * CalculateFogValue(usePerPixelFog));
  }
};

$CODE

float4 fixType(float v){ return v; }
float4 fixType(float2 v){ return float4(v, 0, 0); }
float4 fixType(float3 v){ return float4(v, 0); }
float4 fixType(float4 v){ return v; }

float4 entryPoint(PS_IN pin) : SV_TARGET { 
  return fixType(main(pin));
}
