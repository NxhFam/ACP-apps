/* Template for Lua shaders used by `ui.renderShader()` function */

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

$DEFINES
$TEXTURES

cbuffer cbData : register(b10) { 
  float2 gFrom; 
  float2 gTo; 
  $VALUES
}

struct PS_IN { 
  float4 PosH : SV_POSITION; 
  noperspective float2 Tex : TEXCOORD0; 

  float GetDithering(){  // add this value to output sky color or something like that to avoid banding
    return lerp(0.00196, -0.00196, frac(0.25 + dot(PosH.xy, 0.5)));
  }
};

$CODE

float4 fixType(float v){ return v; }
float4 fixType(float2 v){ return float4(v, 0, 0); }
float4 fixType(float3 v){ return float4(v, 0); }
float4 fixType(float4 v){ return v; }

float4 entryPoint(PS_IN pin) : SV_TARGET { 
  if (any(pin.PosH.xy < gFrom || pin.PosH.xy > gTo)) { discard; }
  return fixType(main(pin));
}
