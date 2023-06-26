# Library ac_chaser_camera

Documentation for ac_chaser_camera. Please note: documentation generator is in development and needs more work, so some information might be missing and other bits might not be fully accurate.

# Module enums.lua



# Module common/common.lua

## Function ac.getCarTags(carIndex)
Get car tags. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Class ac.GenericList
FFI-accelerated list, acts like a regular list (consequent items, size and capacity, automatically growing, etc.)
Doesn’t store nil values to act more like a Lua table.

Few notes:
• Use `:get()` and `:set()` to access elements instead of square brakets;
• Indices are 1-based;
• For fastest access to individual elements use `.raw` field: it’s a raw pointer, so use 0-based indices there and
make sure not to access things outside of list size.

For slightly better performance it might be benefitial to preallocate memory with `list:reserve(expectedSizeOrABitMore)`.

- `ac.GenericList:size()`

  Number of items in the list.

  Returns:

    - `integer`

- `ac.GenericList:sizeBytes()`

  Size of list in bytes (not capacity, for that use `list:capacityBytes()`).

  Returns:

    - `integer`

- `ac.GenericList:isEmpty()`

  Checks if list is empty.

  Returns:

    - `boolean`

- `ac.GenericList:capacity()`

  Capacity of the list.

  Returns:

    - `integer`

- `ac.GenericList:capacityBytes()`

  Size of list in bytes (capacity).

  Returns:

    - `integer`

- `ac.GenericList:reserve(newSize)`

  Makes sure list can fit `newSize` of elements without reallocating memory.

  Parameters:

    1. `newSize`: `integer`

  Returns:

    - `integer`

- `ac.GenericList:shrinkToFit()`

  If capacity is greater than current size, reallocates a smaller bit of memory and moves data there.
function _ac_genericList:shrinkToFit() end

- `ac.GenericList:clear()`

  Removes all elements.
function _ac_genericList:clear() end

- `ac.GenericList:clone()`

  Creates a new list with the same contents as the existing one.

  Returns:

    - `ac.GenericList`
## Class ffilibex
Custom FFI namespace. Be very careful around here.

- `ffilibex.cdef(def, params, ...)`

- `ffilibex.istype(ct, obj)`

  Parameters:

    1. `obj`: `any`

  Returns:

    - `boolean`

- `ffilibex.string(ptr, len)`

  Returns:

    - `string`

- `ffilibex.typeof(ct, params, ...)`

  Returns:

    - `ffi.ctype`

- `ffilibex.cast(ct, init)`

  Parameters:

    1. `init`: `any`

  Returns:

    - `ffi.cdata`

- `ffilibex.metatype(ct, metatable)`

  Parameters:

    1. `metatable`: `table`

  Returns:

    - `ffi.ctype`

- `ffilibex.gc(cdata, finalizer)`

  Returns:

    - `ffi.cdata`
## Function ac.log(...)
Prints a message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.

  Parameters:

  1. `...`: `string|number|boolean` Values.
## Function ac.warn(...)
Prints a warning message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.

  Parameters:

  1. `...`: `string|number|boolean` Values.
## Function ac.error(...)
Prints an error message to a CSP log and to Lua App Debug log. To speed things up and only use Lua Debug app, call `ac.setLogSilent()`.

  Parameters:

  1. `...`: `string|number|boolean` Values.
## Function print(v)
For better compatibility, acts like `ac.log()`.
function print(v) end
## Function ac.skipSaneChecks()
Not doing anything anymore, kept for compatibility.
## Function try(fn, catch, finally)
Calls a function in a safe way, catching errors. If any errors were to occur, `catch` would be
called with an error message as an argument. In either case (with and without error), if provided,
`finally` will be called.

  Parameters:

  1. `fn`: `fun(): T`

  2. `catch`: `fun(err: string)`

  3. `finally`: `fun()|nil`

  Returns:

  - `T|nil`
## Function using(fn, dispose)
Calls a function and then calls `dispose` function. Note: `dispose` function will be called even if
there would be an error in `fn` function. But error would not be contained and will propagate.

  Parameters:

  1. `fn`: `fun(): T?`

  2. `dispose`: `fun()`

  Returns:

  - `T|nil`
## Function ac.store(key, value)
Stores value in session shared Lua/Python storage. This is not a long-term storage, more of a way for
different scripts to exchange data. Note: if you need to exchange a lot of data between Lua scripts,
consider using ac.connect instead.

Data string can contain zeroes.

  Parameters:

  1. `key`: `string`

  2. `value`: `string|number`
## Function ac.load(key)
Reads value from session shared Lua/Python storage. This is not a long-term storage, more of a way for
different scripts to exchange data. Note: if you need to exchange a lot of data between Lua scripts,
consider using ac.connect instead.

  Parameters:

  1. `key`: `string`

  Returns:

  - `nil|string|number`
## Function ac.onRelease(callback)
Adds a callback which might be called when script is unloading. Use it for some state reversion, but
don’t rely on it too much. For example, if Assetto Corsa would crash or just close rapidly, it would not
be called. It should be called when scripts reload though.

  Parameters:

  1. `callback`: `fun()`
## Function package.add(dir)
For easy import of scripts from subdirectories. Provide it a name of a directory relative
to main script folder and it would add that directory to paths it searches for.

  Parameters:

  1. `dir`: `string`
## Function package.relative(path)
Resolves relative path to a Lua module (relative to Lua file you’re running this function from)
so it would be ready to be passed to `require()` function.

Note: performance might be a problem if you are calling it too much, consider caching the result.

  Parameters:

  1. `path`: `string`

  Returns:

  - `string`
## Function io.relative(path)
Resolves relative path to a file (relative to Lua file you’re running this function from)
so it would be ready to be passed to `io` functions (returns full path).

Note: performance might be a problem if you are calling it too much, consider caching the result.

  Parameters:

  1. `path`: `string`

  Returns:

  - `string`
## Function ac.structBytes(data)
Given an FFI struct, returns bytes with its content. Resulting string may contain zeroes.

  Parameters:

  1. `data`: `any` FFI struct (type should be “cdata”).

  Returns:

  - `binary|nil` If data is `nil`, returns `nil`.
## Function ac.fillStructWithBytes(destination, data)
Given an FFI struct and a string of data, fills struct with that data. Works only if size of struct matches size of data. Data string can contain zeroes.

  Parameters:

  1. `destination`: `T` FFI struct (type should be “cdata”).

  2. `data`: `binary` String with binary data.

  Returns:

  - `T`
## Function ac.stringToFFIStruct(src, dst, size)
Fills a string of an FFI struct with data up to a certain size. Make sure to not overfill the data.

  Parameters:

  1. `src`: `string` String to copy.

  2. `dst`: `string` A `const char[N]` field of a struct.

  3. `size`: `integer` Size of `const char[N]` field (N).
## Function ac.onOnlineWelcome(callback)
Sets a callback which will be called when server welcome message and extended config arrive.

  Parameters:

  1. `callback`: `fun(message: string, config: ac.INIConfig)` Callback function.

  Returns:

  - `ac.Disposable`

# Module common/class.lua

## Function ClassBase.isInstanceOf(obj)
Checks if object is an instance of a class created by `class()` function.

  Parameters:

  1. `obj`: `any|nil` Any table, vector, nil, anything.

  Returns:

  - `boolean` True if type of `obj` is `ClassBase` or any class inheriting from it.
## Function ClassBase:isSubclassOf(classDefinition)
Checks if ClassBase is a subsclass of a class created by `class()` function. It wouldn’t be, function is here just for
keeping things even.

  Parameters:

  1. `classDefinition`: `ClassDefinition` Class created by `class()` function.

  Returns:

  - `boolean` Always false.
## Function ClassBase:subclass(...)
Creates a new class. Pretty much the same as calling `class()` (all classes are inheriting from `ClassBase` anyway).

  Returns:

  - `ClassDefinition` New class definition
## Function ClassBase:include(mixin)
Adds a mixin to all subsequently created classes. Use it early in case you want to add a method or some data to all of your objects.
If `mixin` has a property `included`, it would be called each time new class is created with a reference to the newly created class.

  Parameters:

  1. `mixin`: `ClassMixin`
## Function ClassBase:subclassed(classDefinition)
Define this function and it would be called each time a new class without a parent (or `ClassBase` for parent) is created.

  Parameters:

  1. `classDefinition`: `ClassDefinition`
## Function ClassPool.isInstanceOf(obj)
Checks if object is an instance of a class with pooling active.

  Parameters:

  1. `obj`: `any|nil` Any table, vector, nil, anything.

  Returns:

  - `boolean` True if type of `obj` is `ClassPool` or any class inheriting from it.
## Function ClassPool:isSubclassOf(classDefinition)
Checks if ClassPool is a subsclass of a class created by `class()` function. It wouldn’t be unless you’re passing `ClassBase`, function is here just for
keeping things even.

  Parameters:

  1. `classDefinition`: `ClassBase` Class created by `class()` function.

  Returns:

  - `boolean` True if you’ve passed ClassBase here.
## Function ClassPool:subclass(...)
Creates a new class with pooling. Pretty much the same as calling `class(class.Pool, ...)` (all classes with `class.Pool` are 
inheriting from `ClassPool` anyway).

  Returns:

  - `ClassDefinition` New class definition
## Function ClassPool:include(mixin)
Adds a mixin to subsequently created classes with pooling. Use it early in case you want to add a method or some data to all of your objects that use pooling.
If `mixin` has a property `included`, it would be called each time new class with pooling is created with a reference to the newly created class.

  Parameters:

  1. `mixin`: `ClassMixin`
## Function ClassPool:subclassed(classDefinition)
Define this function and it would be called each time a new pooling class without a parent (or `ClassPool` for parent) is created.

  Parameters:

  1. `classDefinition`: `ClassDefinition`
## Class ClassBase
A base class. Note: all classes are inheriting from this one even if they’re not using
`ClassBase` as a parent class explicitly. You might still want to put it in EmmyDoc comment to get hints for functions like `YourClass.isInstanceOf()`.

- `ClassBase:isInstanceOf(classDefinition)`

  Checks if object is an instance of this class. Can be used either as `obj:isInstanceOf(YourClass)` or, as a safer alternative,
`YourClass.isInstanceOf(obj)` — this one would work even if `obj` is nil, a number, a vector, anything like that. And in all of those
cases, of course, it would return `false`.

  Parameters:

    1. `classDefinition`: `ClassDefinition` Used with `obj:isInstanceOf(YourClass)` variant.

  Returns:

    - `boolean` True if argument is an instance of this class.

- `ClassBase:isSubclassOf(classDefinition)`

  Class method. Checks if class itself is a child class of a different class (or a child of a child, etc). 
Can be used as `YourClass:isInstanceOf(YourOtherClass)`.

  Parameters:

    1. `classDefinition`: `ClassDefinition` Class created by `class()` function.

  Returns:

    - `boolean` True if this class is a child of another class (or a child of a child, etc).

- `ClassBase:include(mixin)`

  Class method. Includes mixin, adding new methods to a preexising class. If mixin has a property `included`, it will be called
with an argument referencing a class mixin is being added to. Can be used as `YourClass:include({ newMethod = function(self, arg) end })`.

  Parameters:

    1. `mixin`: `ClassMixin` Any mixin.

- `ClassBase:subclass(...)`

  Class method. Creates a new child class.

  Returns:

    - `ClassDefinition` New class definition

- `ClassBase:subclassed(classDefinition)`

  Class method. Called when a new child class is created using this class as a parent one. Redefine this function for
your class if you need some advanced processing, like adding new methods to a child class.

  Parameters:

    1. `classDefinition`: `ClassDefinition` New class definition
## Class ClassPool
A base class for objects with pooling. Doesn’t add anything, but you can add it as a parent class
so that `recycled()` would be documented.

- `ClassPool:recycled()`

  Called when object is about to get recycled.

  Returns:

    - `boolean` Return false if this object should not be recycled and instead destroyed as usual.
## Function class(name, parentClass, flags)
Create a new class. Example:

```lua
local MyClass = class('MyClass')        -- class declaration

function MyClass:initialize(arg1, arg2) -- constructor
  self.myField = arg1 + arg2            -- field
end

function MyClass:doMyThing()            -- method
  print(self.myField)
end

local instance = MyClass(1, 2)          -- creating instance of a class
instance:doMyThing()                    -- calling a method
```

Whole thing is very similar to [middleclass](https://github.com/kikito/middleclass), but it’s a different
implementation that should be somewhat faster. Main differences:

1. Class name is stored in `YourClass.__name` instead of `YourClass.name`.

2. There is no `.static` subtable, all static fields and methods are instead stored in main class
   table and thus are available as instance fields and methods as well (that’s why `YourClass.name` was
   renamed to `YourClass.__name`, to avoid possible confusion with a common field name). It’s a bit
   messier, especially with class methods such as `:subclass()`, but it has some advantages as well:
   objects creation is faster, and it’s more EmmyLua-friendly (both of which is what it’s all about).

3. Overloaded `__tostring`, `__len` and `__call` are inherited, but not other operators.

4. Method `YourClass.allocate()` works differently here and is used to create a simple table which will be
   passed to `setmetatable()`. This can help with performance if objects are created often.

Everything else should work the same, including inheritance and mixins. As for performance, some simple
tests show up to 30% faster objects creation and 40% less memory used for objects with two fields when
using `YourClass.allocate()` method instead of `YourClass:initialize()` (that alone gives about 15% increase in speed
when creating an object with two fields):

```lua
function YourClass.allocate(arg1, arg2)  -- notice . instead of :
  return { myField = arg1 + arg2 }     -- also notice, methods are not available at this stage
end
```

Other differences (new features rather than something breaking compatibility) and important notes:

1. Function `class()` takes string for class name, another class to act like a parent,
   allocate and initialize functions and flags. Everything is optional and can go in any order (with one caveat:
   allocate function should go before initialize function unless you’re using `class.Pool`). Generally there is no
   benefit in passing allocate and initialize functions here though.

2. With flag `class.NoInitialize` constructor would not look for `YourClass:initialize()` method to call at all,
   instead using only `YourClass.allocate()`. Might speed things up a bit further.

3. If you’re creating new instances really often, there is a `class.Pool` flag. It would disable the use of
   `YourClass.allocate()`, but instead allow to reuse unused objects by using `class.recycle(object)`. Recycled objects
   would end up in a pool of objects to be reused next time an instance would need to be created. Of course, it
   introduces a whole new type of errors (imagine storing a reference to a recycled item somewhere not knowing it was
   recycled and now represents something else entirely), so please be careful.

   Note 1: Method `class.recycle()` can be used with nils or non-recycle, no need to have extra checks before calling it.
 
   Note 2: Instances of child classes won’t end up in parent class pool. For such arrangements, consider adding pooling
           flag to all of child classes where appropriate.

4. Before recycling, method `YourClass:recycled()` will be called. Good time to recycle any inner elements. Also,
   return `false` from it and object would not be recycled at all.

5. To check type, `YourClass.isInstanceOf(item)` can also be used. Notice that it’s a static method, no “:” here.

All classes are considered children classes of `ClassBase`, that one is mostly for EmmyLua to pick up methods like 
`YourClass.isInstanceOf(object)`. If you’re creating your own class and want to use such methods, just add `: ClassBase`
to its EmmyLua annotation. And objects with pooling are children of `ClassPool` which is a child of `ClassBase`. Note: 
to speed things up, those classes aren’t fully real, but you can access them and their methods and even call things like
`ClassBase:include()`. Please read documentation for those functions before using them though, just to check.

  Parameters:

  1. `name`: `string` Class name.

  2. `parentClass`: `ClassBase` Parent class.

  3. `flags`: `nil|integer|'class.NoInitialize'|'class.Pool'|'class.Minimal'` Flags.

  Returns:

  - `ClassDefinition` New class definition
## Function class.recycle(item)
Recycle an item to its pool, to speed up creation and reduce work for GC. Requires class to be created with
`class.Pool` flag.

This method has protection from double recycling, recycling nils or non-recycleable items, so don’t worry about it.

  Parameters:

  1. `item`: `ClassPool|nil`
## Function class.emmy(classFn, constructorFn) return constructorFn
A trick to get `class()` to work with EmmyLua annotations nicely. Call `class.emmy(YourClass, YourClass.initialize)`
or `class.emmy(YourClass, YourClass.allocate)` (whatever you’re using) and it would give you a constructor function.
Then, use it for local reference or as a return value from module. For best results add annotations to function you’re
passing here, such as return value or argument types.

In reality is simply returns the class back and ignores second argument, but because of this definition EmmyLua thinks
it got the constructor.

  Parameters:

  1. `classFn`: `T1`

  2. `constructorFn`: `T2`

  Returns:

  - `T1|T2`

# Module csp.lua

## Function ac.debug(key, value)
Displays value in Lua Debug app, great for tracking state of your values live.

  Parameters:

  1. `key`: `string`

  2. `value`: `any?`
## Function ac.setLogSilent(value)
Stops functions like `ac.log()` from logging things into CSP log file, in case you need to log a lot. With it, you
 can use Lua Debug app to see latest log entries.

  Parameters:

  1. `value`: `boolean?` Default value: `true`.
## Function ac.perfBegin(value)
Simple helper to measure time and analyze performance. Call `ac.perfBegin('someKey')` to start counting time and
 `ac.perfEnd('someKey')` to stop. Measured time will be shown in Lua App Debug app in CSP (moving average across all
 perfBegin/perfEnd calls). Note: keys on perfBegin() and perfEnd() should match.

  Parameters:

  1. `value`: `string`
## Function ac.perfEnd(value)
Simple helper to measure time and analyze performance. Call `ac.perfBegin('someKey')` to start counting time and
 `ac.perfEnd('someKey')` to stop. Measured time will be shown in Lua App Debug app in CSP (moving average across all
 perfBegin/perfEnd calls). Note: keys on perfBegin() and perfEnd() should match.

  Parameters:

  1. `value`: `string`
## Function ac.perfFrameBegin(value)
Unlike `ac.perfBegin('someKey')/ac.perfEnd('someKey')`, `ac.perfFrameBegin(0)/ac.perfFrameEnd(0)` will accumulate time
 between calls as frame progresses and then use the whole sum for moving average. This makes it suitable for measuring
 how much time in a frame repeatedly ran bit of code takes. To keep performance as high as possible (considering that
 it could be ran in a loop), it uses integer keys instead of strings.

  Parameters:

  1. `value`: `integer`
## Function ac.perfFrameEnd(value)
Unlike `ac.perfBegin('someKey')/ac.perfEnd('someKey')`, `ac.perfFrameBegin(0)/ac.perfFrameEnd(0)` will accumulate time
 between calls as frame progresses and then use the whole sum for moving average. This makes it suitable for measuring
 how much time in a frame repeatedly ran bit of code takes. To keep performance as high as possible (considering that
 it could be ran in a loop), it uses integer keys instead of strings.

  Parameters:

  1. `value`: `integer`
## Function ac.dirname()
Returns directory of the script.

  Returns:

  - `string`
## Function ac.findFile(fileName)
If `fileName` is not an absolute path, looks for a file in script directory, then relative to CSP folder,
then relative to AC root folder. If anything is found, returns an absolute path to found file, otherwise
returns input parameter.

  Parameters:

  1. `fileName`: `string` File name relative to script folder, or CSP folder, or AC root folder.

  Returns:

  - `string`
## Function ac.getPatchVersion()

  Returns:

  - `string`
## Function ac.getPatchVersionCode()
Increments with every CSP build.

  Returns:

  - `integer`
## Function ac.getFolder(folderID)
Returns full path to one of known folders.

  Parameters:

  1. `folderID`: `ac.FolderID`

  Returns:

  - `string`
## Function ac.getTrackId()
Use `ac.getTrackID()` instead.

  Returns:

  - `string`
## Function ac.getTrackID()
Returns track ID (name of its folder).

  Returns:

  - `string`
## Function ac.getTrackLayout()
Returns track layout ID (name of layout folder, without name of track folder), or empty string if there is no layout.

  Returns:

  - `string`
## Function ac.getTrackFullID(separator)
Returns full track ID (name of track folder and layout folder joined by some string, or just name of track folder if there is no layout).

  Parameters:

  1. `separator`: `string?` Default value: '-'.

  Returns:

  - `string`
## Function ac.getTrackName()
Returns track name (as set in its JSON file).

  Returns:

  - `string`
## Function ac.getCameraPosition()

  Returns:

  - `vec3`
## Function ac.getCameraUp()

  Returns:

  - `vec3`
## Function ac.getCameraSide()

  Returns:

  - `vec3`
## Function ac.getCameraForward()

  Returns:

  - `vec3`
## Function ac.getCameraDirection()
This vector is pointing backwards! Only kept for compatibility. For proper one, use `ac.getCameraForward()`.

  Returns:

  - `vec3`
## Function ac.getCameraFOV()
Value in degrees.

  Returns:

  - `number`
## Function ac.getCameraPositionTo(r)

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.getCameraUpTo(r)

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.getCameraSideTo(r)

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.getCameraForwardTo(r)

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.getCameraDirectionTo(r)

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.getCameraPositionRelativeToCar()
Returns camera position in car coordinates system.

  Returns:

  - `vec3`
## Function ac.getCompassAngle(dir)
Returns compass angle for given directory.

  Parameters:

  1. `dir`: `vec3`

  Returns:

  - `number` Angle from 0 to 360 (0/360 for north, 90 for east, etc.)
## Function ac.getSunAngle()
Value in degrees.

  Returns:

  - `number`
## Function ac.getSunPitchAngle()
Value in degrees.

  Returns:

  - `number`
## Function ac.getSunHeadingAngle()
Value in degrees.

  Returns:

  - `number`
## Function ac.isInteriorView()
Returns true if camera is focused on interior (interior audio is playing).

  Returns:

  - `boolean`
## Function ac.isInReplayMode()

  Returns:

  - `boolean`
## Function ac.setTextureKey(key)

  Parameters:

  1. `key`: `string|nil` Default value: `nil`.
## Function ac.encodeTexture(filename, outputFilename, key, applyLz4Compression)

  Parameters:

  1. `filename`: `string`

  2. `outputFilename`: `string`

  3. `key`: `string`

  4. `applyLz4Compression`: `boolean|`true`|`false``
## Function ac.compressTexture(filename, outputFilename)

  Parameters:

  1. `filename`: `string`

  2. `outputFilename`: `string`
## Function ac.getSoundSpeedMs()
Returns precalculated sound speed in m/s taking into account humidity, altitude, pressure, etc.

  Returns:

  - `number`
## Function ac.getAirPressure(p)
Returns air pressure in kPa.

  Parameters:

  1. `p`: `vec3`

  Returns:

  - `number`
## Function ac.getAirHumidity(p)
Returns air humidity in 0…1 range. Currently doesn’t use position parameter, but it might change later.

  Parameters:

  1. `p`: `vec3`

  Returns:

  - `number`
## Function ac.getLastError()
Returns string with last error thrown by this script, or `nil` if there wasn’t an error. Use it in case you would want to set some nicer error reporting.

  Returns:

  - `string`
## Function ac.lapTimeToString(time, allowHours)
Turns time in milliseconds into common lap time presentation, like 00:00.123. If minutes exceed 60,
hours will also be added, but only if `allow_hours` is `true` (default is `false`).

  Parameters:

  1. `time`: `number`

  2. `allowHours`: `boolean?` Set to \`true\` to add hours as well. If \`false\` (default value), instead it would produce 99:99.999. Default value: `false`.

  Returns:

  - `string`
## Function ac.getCountryName(nationCode)
Returns country name based on nation code (three symbols for country ID).

  Parameters:

  1. `nationCode`: `ac.NationCode`

  Returns:

  - `string`
## Function ac.getAudioVolume(audioChannelKey)
Returns audio volume for given channel, value from 0 to 1. If channel is not recognized, returns -1.

  Parameters:

  1. `audioChannelKey`: `ac.AudioChannel`

  Returns:

  - `number` Value from 0 to 1.
## Function ac.getAudioOutputDevice()
Returns name of output audio device.

  Returns:

  - `string`
## Function ac.getCarSpeedKmh(carIndex)
Consider using `ac.getCar(carIndex).speedKmh` instead.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `number`
## Function ac.getGroundYApproximation()
Returns approximate Y coordinate of ground, calculated by using depth from reflection cubemap. Does not have a performance impact (that value
 will be calculated anyway for CSP to run.

  Returns:

  - `number`
## Function ac.getDeltaT()
Returns current delta time associated with UI (so values are non-zero if sim or replay are paused).

  Returns:

  - `number` Seconds.
## Function ac.getGameDeltaT()
Returns current delta time associated with simulation (so values are zero if sim or replay are paused).

  Returns:

  - `number` Seconds.
## Function ac.getScriptDeltaT()
Returns delta time for current script. If script only runs every N frames (like car display scripts by default),
this value will be greater than regular `dt` from simulation state.

  Returns:

  - `number`
## Function ac.getConditionsTimeScale()
Returns current time multiplier.

  Returns:

  - `number`
## Function ac.getPpFilter()
Returns name of current PP filter with “.ini”.

  Returns:

  - `string`
## Function ac.getWindVelocity()
Value is in m/s.

  Returns:

  - `vec3`
## Function ac.getWindVelocityTo(r)
Value is in m/s.

  Parameters:

  1. `r`: `vec3` Destination.
## Function ac.readDataFile(value)
Can be used to access files in data.acd and, for example, read car specs

  Parameters:

  1. `value`: `string`

  Returns:

  - `string`
## Function ac.parseINIppFile(iniData)
Parse INIpp configuration file, return it as JSON. Deprecated, use `ac.INIConfig.parse()` instead.

  Parameters:

  1. `iniData`: `string`

  Returns:

  - `string`
## Function ac.loadINIppFile(iniFilename, includeDirs)
Load and parse INIpp configuration file (supports includes and such), return it as JSON. Deprecated, use `ac.INIConfig.load()` instead.

  Parameters:

  1. `iniFilename`: `string`

  2. `includeDirs`: `string|nil` Newline separated path to folders to search for included files in. Default value: `nil`.

  Returns:

  - `string`
## Function ac.isWeatherFxActive()

  Returns:

  - `boolean`
## Function ac.getTrackCoordinatesDeg()
Returns track world coordinates in degrees.

  Returns:

  - `vec2` X for lattitude, Y for longitude.
## Function ac.getTrackTimezoneBaseDst()
Returns timezone offset for the track in seconds.

  Returns:

  - `vec2` X for base offset, Y for summer time offset.
## Function ac.getMGUKDeliveryName(carIndex, programIndex)
Returns name of MGUK delivery program. If there is no such car or program, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `programIndex`: `integer?` 0-based program index (if negative, name of currently selected program will be returned. Default value: -1.

  Returns:

  - `string`
## Function ac.getTrackSectorName(trackProgress)
Name of a sector.

  Parameters:

  1. `trackProgress`: `number` Track position from 0 to 1.

  Returns:

  - `string`
## Function ac.getTrackUpcomingTurn(carIndex)
Distance and turn angle (in degrees) for the upcoming turn. If failed to compute, both would be -1. If car is facing wrong way, turn angle is either
180° or -180° depending on where steering wheel of a car is.

  Parameters:

  1. `carIndex`: `integer?` Default value: 0.

  Returns:

  - `vec2`
## Function ac.getTyresName(carIndex, compoundIndex)
Get short name of a tyre set, either currently selected or with certain index. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `compoundIndex`: `integer?` 0-based tyre set index, if set to -1, short name of currently selected tyre set will be returned. Default value: -1.

  Returns:

  - `string`
## Function ac.getTyresIndex(carIndex, tyresShortName)
Get 0-based index of a tyres set with a given short name, or -1 if there is no such tyres set (or such car).

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `tyresShortName`: `string` Short tyres set name (usually a couple of symbols long).

  Returns:

  - `integer`
## Function ac.getTyresLongName(carIndex, compoundIndex)
Returns long name of a tyre set with certain index. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `compoundIndex`: `integer?` 0-based tyre set index, if set to -1, short name of currently selected tyre set will be returned. Default value: -1.

  Returns:

  - `string`
## Function ac.getCarID(carIndex)
Get car ID (name of its folder) of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getCarName(carIndex, includeYearPostfix)
Get car name (from its JSON file) of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `includeYearPostfix`: `boolean?` Set to \`true\` to add a year postfix. Default value: `false`.

  Returns:

  - `string`
## Function ac.getCarSkinID(carIndex)
Get selected skin ID of (name of skin’s folder) of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getCarBrand(carIndex)
Get name of a manufacturer of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getCarCountry(carIndex)
Get name of manufactoring country of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getDriverName(carIndex)
Get full driver name of a driver of a certain car. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getDriverNationCode(carIndex)
Get three character nation code of a driver of a certain car. Nation code is a three-letter uppercase country identifier. If nationality is not set, a value from JSON
is returned. If it’s missing there, a fallback “ITA” is returned. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getDriverNationality(carIndex)
Get full nationality of a driver of a certain car. Usually, it’s a full country name. If nationality is not set, a value from JSON
is returned. If it’s missing there, a fallback “Italy” is returned. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getDriverTeam(carIndex)
Get name of a team of a driver of a certain car. Team names can be configured in entry list online. If nationality is not set, a value from JSON
is returned. If it’s missing there, an empty string is returned. If there is no such car, returns `nil`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `string`
## Function ac.getDriverNumber(carIndex)
Get number of a driver of a certain car. If number is set in skin JSON, it will be returned, otherwise it’s a unique 1-based number.
If there is no car with such index, 0 is returned.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `integer`
## Function ac.isCustomIconSet(carIndex)
Returns `true` if a certain driver is using custom icon. Use `'carN::special::driver'` as image filename to draw it (when not custom,
will give you a livery icon or a fallback dark image).

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `boolean`
## Function ac.getSessionName(sessionIndex)
Get session name for a session with given index. Use `ac.getSim()` to check number of sessions and more information about them.
If there is no such session, returns `nil`.

  Parameters:

  1. `sessionIndex`: `integer`

  Returns:

  - `string`
## Function ac.isKeyDown(keyIndex)
Is keyboard button being held.

  Parameters:

  1. `keyIndex`: `ac.KeyIndex`

  Returns:

  - `boolean`
## Function ac.isKeyPressed(keyIndex)
Is keyboard button just moved from not held to held.

  Parameters:

  1. `keyIndex`: `ac.KeyIndex`

  Returns:

  - `boolean`
## Function ac.isKeyReleased(keyIndex)
Is keyboard button just moved from held to not held.

  Parameters:

  1. `keyIndex`: `ac.KeyIndex`

  Returns:

  - `boolean`
## Function ac.getControllerSteerValue()
Returns steering input from -1 to 1.

  Returns:

  - `number`
## Function ac.isControllerGasPressed()
Is gas input pressed (pedal, gamepad axis, keyboard button but not mouse button).

  Returns:

  - `boolean`
## Function ac.isControllerGearUpPressed()
Is gear up input pressed (pedal, gamepad button, keyboard button).

  Returns:

  - `boolean`
## Function ac.isControllerGearDownPressed()
Is gear down input pressed (pedal, gamepad button, keyboard button).

  Returns:

  - `boolean`
## Function ac.getSessionSpawnSet(sessionIndex)
Get session spawn set (`'START'`, `'PIT'`, `'HOTLAP_START'`, `'TIME_ATTACK'`, etc.) for a session with given index. Use `ac.getSim()`
to check number of sessions and more information about them. If there is no such session, returns `nil`.

  Parameters:

  1. `sessionIndex`: `integer`

  Returns:

  - `string`
## Function ac.forceVisibleHeadNodes(carIndex, force)
Forces driver head to be visible even with cockpit camera.

  Parameters:

  1. `carIndex`: `integer`

  2. `force`: `boolean?` Default value: `true`.
## Function ac.hasTrackSpline()
Refers to AI spline.

  Returns:

  - `boolean`
## Function ac.worldCoordinateToTrackProgress(v)
Finds nearest point on track AI spline (fast_lane) and returns its normalized position. If there is no track spline, returns -1.

  Parameters:

  1. `v`: `vec3`

  Returns:

  - `number`
## Function ac.getTrackAISplineSides(v)
Returns distance from AI spline to left and right track boundaries.

  Parameters:

  1. `v`: `number` Lap progress from 0 to 1.

  Returns:

  - `vec2` X for left side, Y for right side.
## Function ac.trackProgressToWorldCoordinate(v)

  Parameters:

  1. `v`: `number`

  Returns:

  - `vec3`
## Function ac.trackProgressToWorldCoordinateTo(v, r)

  Parameters:

  1. `v`: `number`

  2. `r`: `vec3`
## Function ac.worldCoordinateToTrack(v)
Converts world coordinates into track coordinates. Track coordinates:
 - X for normalized position (0 — right in the middle, -1 — left side of the track, 1 — right size);
 - Y for height above track in meters;
 - Z for track progress.

  Parameters:

  1. `v`: `vec3`

  Returns:

  - `vec3`
## Function ac.trackCoordinateToWorld(v)
Converts track coordinates into world coordinates. Track coordinates:
 - X for normalized position (0 — right in the middle, -1 — left side of the track, 1 — right size);
 - Y for height above track in meters;
 - Z for track progress.

  Parameters:

  1. `v`: `vec3`

  Returns:

  - `vec3`
## Function ac.isVisibleInMainCamera(pos, radius)
Checks visibility with frustum culling.

  Parameters:

  1. `pos`: `vec3`

  2. `radius`: `number`

  Returns:

  - `boolean`
## Function ac.setSystemMessage(msg, description)

  Parameters:

  1. `msg`: `string`

  2. `description`: `string`
## Function ac.isGamepadButtonPressed(gamepadIndex, gamepadButtonID)
Checks if a certain gamepad button is pressed.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 0 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  2. `gamepadButtonID`: `ac.GamepadButton`

  Returns:

  - `boolean`
## Function ac.getGamepadAxisValue(gamepadIndex, gamepadAxisID)
Returns value of a certain gamepad axis.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 0 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  2. `gamepadAxisID`: `ac.GamepadAxis`

  Returns:

  - `number`
## Function ac.getJoystickCount()
Returns number of DirectInput devices (ignore misleading name).

  Returns:

  - `integer`
## Function ac.getJoystickName(joystick)
Returns name of a DirectInput device (ignore misleading name). If there is no such device, returns `nil`.

  Parameters:

  1. `joystick`: `integer` 0-based index.

  Returns:

  - `string`
## Function ac.getJoystickAxisCount(joystick)
While this function returns accurate number of device axis, consider using 8 instead if you need to iterate over them.
Actual axis can be somewhere within those 8. For example, if device has a single axis, it could be that you need to access
axis at index seven to get its value (rest will be zeroes).

  Parameters:

  1. `joystick`: `integer`

  Returns:

  - `integer`
## Function ac.getJoystickButtonsCount(joystick)
Returns number of buttons of a DirectInput device (ignore misleading name).

  Parameters:

  1. `joystick`: `integer`

  Returns:

  - `integer`
## Function ac.getJoystickDpadsCount(joystick)
Returns number of D-pads (aka POVs) of a DirectInput device (ignore misleading name).

  Parameters:

  1. `joystick`: `integer`

  Returns:

  - `integer`
## Function ac.isJoystickButtonPressed(joystick, button)
Checks if a button of a DirectInput device is pressed (ignore misleading name).

  Parameters:

  1. `joystick`: `integer`

  2. `button`: `integer`

  Returns:

  - `boolean`
## Function ac.getJoystickAxisValue(joystick, axis)
Returns axis value of a DirectInput device (ignore misleading name).

  Parameters:

  1. `joystick`: `integer`

  2. `axis`: `integer`

  Returns:

  - `number`
## Function ac.isJoystickAxisValue(joystick, axis)
Use `ac.getJoystickAxisValue()` instead.

  Parameters:

  1. `joystick`: `integer`

  2. `axis`: `integer`

  Returns:

  - `number`
## Function ac.getJoystickDpadValue(joystick, dpad)
Returns D-pad (aka POV) value of a DirectInput device (ignore misleading name).

  Parameters:

  1. `joystick`: `integer`

  2. `dpad`: `integer`

  Returns:

  - `integer`
## Function ac.isJoystickDpadValue(joystick, dpad)
Use `ac.getJoystickDpadValue()` instead.

  Parameters:

  1. `joystick`: `integer`

  2. `dpad`: `integer`

  Returns:

  - `integer`
## Function ac.getPenPressure()
Checks current stylus/pen/mouse using RealTimeStylus API (compatible with Windows Ink). Should support things like Wacom tables (if drivers are installed
and Windows Ink compatibility in options is not disabled).

Note: the moment its called, CSP initializes RealTimeStylus API to monitor pen state until game closes. With that, CSP will also use that data
for mouse (or pen) pointer interaction with UI in general, especially for IMGUI apps.
[There is a weird issue in Windows 10](https://answers.microsoft.com/en-us/windows/forum/all/windows-pen-tablet-click-and-drag-lag/9e4cac7d-69a0-4651-87e8-7689ce0d1027)
where it doesn’t register short click-and-drag events properly expecting a touchscreen gesture. Using RealTimeStylus API for UI in general solves that.

  Returns:

  - `number` Pen pressure from 0 to 1 (if mouse is used, pressure is 1).
## Function ac.setClipboadText(text)
Sets diven text to the clipboard.

  Parameters:

  1. `text`: `string`
## Function ac.getTrackDataFilename(name)
Given name, returns a path like …/assettocorsa/content/tracks/[track ID]/data/[name], taking into account layout as well.

  Parameters:

  1. `name`: `string`

  Returns:

  - `string`
## Function ac.getCarLeaderboardPosition(carIndex)
Returns leaderboard car position, same as Python function with the same name. Does not work online. For an alternative solution,
get position calculated by CSP via `ac.getCar(N).racePosition`

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `integer` Returns -1 if couldn’t calculate the value.
## Function ac.getCarRealTimeLeaderboardPosition(carIndex)
Returns real time car position, same as Python function with the same name. Does not work online. For an alternative solution,
get position calculated by CSP via `ac.getCar(N).racePosition`.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  Returns:

  - `integer` Returns -1 if couldn’t calculate the value.
## Function ac.console(message, withoutPrefix)
Prints message to AC console.

  Parameters:

  1. `message`: `string`

  2. `withoutPrefix`: `boolean?` Default value: `false`.
## Function ac.setMessage(title, description)
Show message using AC system messages UI.

  Parameters:

  1. `title`: `string`

  2. `description`: `string`
## Function ac.getMoonFraction()
How much of moon area is currently lit up.

  Returns:

  - `number`
## Function ac.getAltitude()

  Returns:

  - `number`
## Function ac.getSkyFeatureDirection(skyFeature, distance)
Get direction to a sky feature in world-space (corrected for track heading). If feature is not available, returns a zero vector.

  Parameters:

  1. `skyFeature`: `ac.SkyFeature`

  2. `distance`: `number|refnumber|nil` Default value: `nil`.

  Returns:

  - `vec3`
## Function ac.getSkyStarDirection(declRad, rightAscRad)
Get direction to a star in the sky in world-space (corrected for track heading). If feature is not available, returns a zero vector.

  Parameters:

  1. `declRad`: `number`

  2. `rightAscRad`: `number`

  Returns:

  - `vec3`
## Function ac.getServerName()
Returns name of the current online server, or `nil` if it’s not available.

  Returns:

  - `string`
## Function ac.getServerIP()
Returns IP address of the current online server, or `nil` if it’s not available.

  Returns:

  - `string`
## Function ac.getServerPortHTTP()
Returns HTTP post of the current online server, or -1 if it’s not available.

  Returns:

  - `integer`
## Function ac.getServerPortTCP()
Returns TCP post of the current online server, or -1 if it’s not available.

  Returns:

  - `integer`
## Function ac.getServerPortUDP()
Returns UDP post of the current online server, or -1 if it’s not available.

  Returns:

  - `integer`
## Function ac.getCarByDriverName(driverName)
Returns index of a car with a driver with a certain name, or -1 if there is no such car.

  Parameters:

  1. `driverName`: `string`

  Returns:

  - `integer`
## Function ac.refreshCarShape(carIndex)
Call this function if your script caused car shape to change and CSP would refresh interior masking, car heightmap and more.

  Parameters:

  1. `carIndex`: `integer?` Default value: 0.
## Function ac.refreshCarColor(carIndex)
Call this function if your script caused car color to change and CSP would refresh color map for bounced light and more.

  Parameters:

  1. `carIndex`: `integer?` Default value: 0.
## Function ac.updateDriverModel(carIndex)
Updates state of high-res driver model. Use it before moving driver nodes manually for extra animations: if called,
 next model update possibly overwriting your custom positioning will be skipped. Also, model update will be enforced
 so you can blend your custom state.

  Parameters:

  1. `carIndex`: `integer?` For car scripts, always applied to associated car instead. Default value: -1.
## Function ac.encodeHalf(v)
Encodes float into FP16 format and returns it as uint16.

  Parameters:

  1. `v`: `number`

  Returns:

  - `integer`
## Function ac.encodeHalf2(v)
Encodes two floats from a vector into FP16 format and returns it as uint32.

  Parameters:

  1. `v`: `vec2`

  Returns:

  - `integer`
## Function ac.decodeHalf(v)
Decodes float from FP16 format (represented as uint16) and returns a regular number.

  Parameters:

  1. `v`: `integer`

  Returns:

  - `number`
## Function ac.decodeHalf2(v)
Decodes two floats from FP16 format (represented as uint32) and returns a vector.

  Parameters:

  1. `v`: `integer`

  Returns:

  - `vec2`
## Function ac.getDriverHeadTransformTo(ret, carIndex)

  Parameters:

  1. `ret`: `mat4x4`

  2. `carIndex`: `integer`

  Returns:

  - `boolean`
## Function ac.onSessionStart(callback)
Sets a callback which will be called when a new session starts (or restarts).

  Parameters:

  1. `callback`: `fun(sessionIndex: integer, restarted: boolean)` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onCarJumped(carIndex, callback)
Sets a callback which will be called when car teleports somewhere or its state gets reset.

  Parameters:

  1. `carIndex`: `integer` 0-based car index, or -1 for an event to be called for all car.

  2. `callback`: `fun(carID: integer)` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onClientConnected(callback)
Sets a callback which will be called when new user connects the server and their car appears (doesn’t do anything outside of online race).

  Parameters:

  1. `callback`: `fun(connectedCarIndex: integer, connectedSessionID: integer)` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onClientDisconnected(callback)
Sets a callback which will be called when a user disconnects (doesn’t do anything outside of online race).

  Parameters:

  1. `callback`: `fun(connectedCarIndex: integer, connectedSessionID: integer)` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onControlSettingsChanged(callback)
Sets a callback which will be called when control settings change live.

  Parameters:

  1. `callback`: `fun()` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onTripleConfigurationChanged(callback)
Sets a callback which will be called when triple screen configuration changes.

  Parameters:

  1. `callback`: `fun()` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onFileChanged(filename, callback)
Sets a callback which will be called when a file changes.

  Parameters:

  1. `filename`: `string` Full path to a file to monitor.

  2. `callback`: `fun()` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onFolderChanged(folder, filter, recursive, callback)
Sets a callback which will be called when folder contents change.

  Parameters:

  1. `folder`: `string` Full path to a directory to monitor.

  2. `filter`: `string` CSP filter (? for any number of any symbols, regex if “\`” quotes are used, or a complex query) applied to full file path, or \`nil\`.

  3. `recursive`: `boolean|`true`|`false`` If \`true\`, changes in subfolders are also detected.

  4. `callback`: `fun(files: string[])` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onCSPConfigChanged(cspModuleID, callback)
Sets a callback which will be called when config for certain CSP module has changed.

  Parameters:

  1. `cspModuleID`: `ac.CSPModuleID` ID of a module to monitor.

  2. `callback`: `fun()` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.onScreenshot(callback)
Sets a callback which will be called when a new screenshot is made.

  Parameters:

  1. `callback`: `fun()` Callback function.

  Returns:

  - `ac.Disposable`
## Function ac.checksumSHA256(data)
Computes SHA-256 checksum for given binary data. Very secure, but might be slow with large amounts of data. Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  Returns:

  - `string`
## Function ac.checksumXXH(data)
Computes 64-bit xxHash checksum for given binary data. Very fast, not that great for encryption purposes.
Use `bit.tohex()` to turn result into a hex representation. Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  Returns:

  - `integer`
## Function ac.uniqueMachineKey()
A key unique for each individual PC (uses serial numbers of processor and motherboard).
Use `ac.uniqueMachineKeyAsync()` instead.

  Returns:

  - `string`
## Function ac.uniqueMachineKeyAsync(callback)
A key unique for each individual PC (uses serial numbers of processor and motherboard). Asyncronous version.

  Parameters:

  1. `callback`: `fun(err: string, data: string)`
## Function ac.compress(data, type, level)
Compresses data. First byte of resulting data is compression type, next four are uncompressed data size, rest is compressed data
itself. If data is failed to compress, returns `nil`. Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  2. `type`: `ac.CompressionType`

  3. `level`: `integer?` Higher level means better, but slower compression. Maximum value: 12. Default value: 9.

  Returns:

  - `string`
## Function ac.decompress(data)
Decompresses data. First byte of input data is compression type, next four are uncompressed data sizea. If data is damaged, returns `nil`.
Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  Returns:

  - `string`
## Function ac.storageSetPath(relativePath, prefix)
Changes location of script storage. Available only for scripts with I/O access.

  Parameters:

  1. `relativePath`: `string` Path relative to directory with Lua configs*/.

  2. `prefix`: `string|nil` Optional prefix. Default value: `nil`.
## Function ac.encodeBase64(data, trimResult)
Encodes data in base64 format. Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  2. `trimResult`: `boolean?` If \`true\`, ending “=” will be trimmed. Default value: `false`.

  Returns:

  - `string`
## Function ac.decodeBase64(data)
Decodes data from base64 format (ending “=” are not needed).

  Parameters:

  1. `data`: `string`

  Returns:

  - `string`
## Function ac.utf8To16(data)
Converts string from UTF-8 to UTF-16 format (two symbols per character). All strings Lua operates with regularly are consired UTF-8. UTF-16 strings
can’t be used in any CSP API unless documentation states that function can take strings containing zeroes.

  Parameters:

  1. `data`: `string`

  Returns:

  - `string`
## Function ac.utf16To8(data)
Converts string from UTF-16 (two symbols per character) to common Lua UTF-8. All strings Lua operates with regularly are consired UTF-8. UTF-16 strings
can’t be used in any CSP API unless documentation states that function can take strings containing zeroes. Data string can contain zero bytes.

  Parameters:

  1. `data`: `binary`

  Returns:

  - `string`
## Function ac.broadcastSharedEvent(key, data)
Broadcasts a shared event. With shared events, different Lua scripts can exchange messages and data. Make sure to come up with
a unique name for your events to avoid collisions with other scripts and Lua apps.

Callbacks will be called next time the script is updating.

Note: if your scripts need to exchange data frequently, consider using `ac.connect()` instead, as it allows to establish a typed connection
with much less overhead.

  Parameters:

  1. `key`: `string`

  2. `data`: `serializable`

  Returns:

  - `integer` Returns number of listeners to the event with given key.
## Function ac.onSharedEvent(key, callback, processPostponed)
Subscribes to a shared event. With shared events, different Lua scripts can exchange messages and data. Make sure to come up with
a unique name for your events to avoid collisions with other scripts and Lua apps.

Callback will be called next time this script is updating.

  Parameters:

  1. `key`: `string`

  2. `callback`: `fun(data: string|number|boolean|nil, senderName: string, senderType: string)` Callback function. Data might be \`nil\`.

  3. `processPostponed`: `boolean?` Set to \`true\` to process previously broadcasted and yet non-processed events (up to 40). Default value: `false`.

  Returns:

  - `ac.Disposable`
## Function ac.setVRHandBusy(hand, busy)

  Parameters:

  1. `hand`: `integer` 0 for left, 1 for right.

  2. `busy`: `boolean|`true`|`false`` Busy hand doesn’t have visual marks and doesn’t interact with UI and car elements.
## Function ac.setVRHandVibration(hand, frequency, amplitude, duration)

  Parameters:

  1. `hand`: `integer` 0 for left, 1 for right.

  2. `frequency`: `number`

  3. `amplitude`: `number`

  4. `duration`: `number?` Duration in seconds. Default value: 0.01.
## Function ac.isModuleActive(cspModuleID)

  Parameters:

  1. `cspModuleID`: `ac.CSPModuleID`

  Returns:

  - `boolean`
## Function ac.getCarIndexInFront(carMainIndex, distance)
Returns index of a car in front of other car (within 100 m), or -1 if there is no such car.

  Parameters:

  1. `carMainIndex`: `integer`

  2. `distance`: `number|refnumber|nil` Default value: `nil`.

  Returns:

  - `integer`
## Function ac.getGapBetweenCars(carMainIndex, carComparingToIndex)
Calculates time gap between two cars in seconds. In race sessions uses total driven distance and main car speed, in other sessions simply
compares best lap times. If main car is ahead of comparing-to car (in front of, or has better lap time for non-race sessions), value will
be negative.

In the future implementation might change for something more precise.

  Parameters:

  1. `carMainIndex`: `integer` 0-based index.

  2. `carComparingToIndex`: `integer` 0-based index.

  Returns:

  - `number`
## Function io.getAttributes(filename)
Gets file attributes.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `io.FileAttributes`
## Function io.getMainExecutable()
Gets full filename of the main AC executable (“…/acs.exe” for most cases).

  Returns:

  - `string`
## Function io.loadAsync(filename, callback)
Reads file content into a string, if such file exists, otherwise returns fallback data or `nil`. Asyncronous version.

  Parameters:

  1. `filename`: `string`

  2. `callback`: `fun(err: string, data: string)`
## Function io.save(filename, data)
Writes data into a file, returns `true` if operation was successfull. Data string can contain zero bytes.

  Parameters:

  1. `filename`: `string`

  2. `data`: `binary`

  Returns:

  - `boolean`
## Function io.saveAsync(filename, data, callback)
Writes data into a file from a different thread, returns `true` via callback if operation was successfull. Data string can contain zero bytes.

  Parameters:

  1. `filename`: `string`

  2. `data`: `binary`

  3. `callback`: `fun(err: string)`
## Function io.exists(filename)
Checks if file or directory exists. If you need to know specifically if a file or directory exists, use `io.dirExists(filename)` or `io.fileExists(filename)`.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.dirExists(filename)
Checks if directory exists. If there is a file in its place, it would return `false`.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.fileExists(filename)
Checks if file exists. If there is a directory in its place, it would return `false`.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.fileSize(filename)
Calculates file size in bytes. Returns -1 if there was an error.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `integer`
## Function io.creationTime(filename)
Returns creation time as number of seconds since 1970, or -1 if there was an error.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `integer`
## Function io.lastAccessTime(filename)
Returns last access time as number of seconds since 1970, or -1 if there was an error.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `integer`
## Function io.lastWriteTime(filename)
Returns last write time as number of seconds since 1970, or -1 if there was an error.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `integer`
## Function io.createDir(filename)
Creates new directory, returns `true` if directory was created. If parent directories are missing, they’ll be created as well.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.isFileNameAcceptable(fileName)
Checks if file name is acceptable, returns `true` if there are no prohibited symbols in it (unlike `io.isFileNameAcceptable()`, does not allow slashes).

  Parameters:

  1. `fileName`: `string`

  Returns:

  - `boolean`
## Function io.isFilePathAcceptable(filename)
Checks if full file name is acceptable, returns `true` if there are no prohibited symbols in it (unlike `io.isFileNameAcceptable()`, does allow slashes).

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.move(existingFilename, newFilename)
Moves a file or a directory with all of its contents to a new place, returns `true` if moved successfully. Can be used for moving or renaming things.

  Parameters:

  1. `existingFilename`: `string`

  2. `newFilename`: `string`

  Returns:

  - `boolean`
## Function io.copyFile(existingFilename, newFilename, failIfExists)
Copies a file to a new place, returns `true` if moved successfully.

  Parameters:

  1. `existingFilename`: `string`

  2. `newFilename`: `string`

  3. `failIfExists`: `boolean?` Set to \`false\` to silently overwrite existing files. Default value: `true`.

  Returns:

  - `boolean`
## Function io.deleteFile(filename)
Deletes a file, returns `true` if file was deleted successfully. To delete empty directory, use `io.deleteDir()`. If you’re operating around important
files, consider using `io.recycle()` instead.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.deleteDir(filename)
Deletes an empty directory, returns `true` if directory was deleted successfully. To delete a file, use `io.deleteFile()`.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.recycle(filename)
Moves file to Windows Recycle Bin, returns `true` if file was moved successfully. Note: this operation is much slower than removing a file with `io.deleteFile()`
or removing an empty directory with `io.deleteDir()`.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `boolean`
## Function io.loadFromZip(zipFilename, entryFilename)
Loads file from an archive as a string. Archive would remain open for some time to speed up consequent reads. If failed, returns `nil`.

  Parameters:

  1. `zipFilename`: `string`

  2. `entryFilename`: `string`

  Returns:

  - `string`
## Function io.checksumSHA256(filename, callback)
Computes SHA-256 checksum of a given file, returns result in a callback.

  Parameters:

  1. `filename`: `string`

  2. `callback`: `fun(err: string, checksum: string)`
## Function os.dateGlobal(format, timestamp)
Returns formatted date. Same as `os.date()`, but returned value does not include system timezome.

  Parameters:

  1. `format`: `string`

  2. `timestamp`: `integer`

  Returns:

  - `string`
## Function os.addDLLDirectory(filename)
Adds new directory to look for DLL files in.

  Parameters:

  1. `filename`: `string` If not absolute, considered to be relative to script root folder.
## Function os.execute(cmd, timeoutMs, windowless)
Altered version of regular `os.execute()`: allows to specify timeout and doesn’t show a new window.
 Note: please consider using `os.runConsoleProcess()` instead: it’s a lot more robust, asyncronous and tweakable.

  Parameters:

  1. `cmd`: `string`

  2. `timeoutMs`: `integer?` Default value: -1.

  3. `windowless`: `boolean?` Default value: `true`.

  Returns:

  - `integer`
## Function os.showMessage(msg, type)
Show a popup message using good old MessageBox. Please do not use it for debugging, instead consider using `ac.log()` and `ac.debug('key', 'value')`
with in-game Lua Debug App.
Note: do not rely on this function, most likely it might be removed in the future as obstructing.

  Parameters:

  1. `msg`: `string`

  2. `type`: `integer?` Type of MessageBox according to WinAPI. Default value: 0.

  Returns:

  - `integer`
## Function os.showInExplorer(filename)
Shows file in Windows Explorer (opens folder with it and selects the file).

  Parameters:

  1. `filename`: `string`
## Function os.openInExplorer(directory)
Opens file or directory in Windows Explorer. If it’s a file, associated program will be launched instead.

  Parameters:

  1. `directory`: `string`
## Function os.findAssociatedExecutable(filename)
Tries to find a program associated with a filename. Returns path to it, or `nil` if nothing was found.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `string`
## Function os.openTextFile(filename, line)
Opens text file at given line in a default text editor. Supports VS Code, Notepad++, Sublime Text and Atom (they all use different
arguments for line number.

  Parameters:

  1. `filename`: `string`

  2. `line`: `integer`
## Function os.openURL(url)
Opens URL in default system browser.

  Parameters:

  1. `url`: `string`
## Function os.preciseClock()
Returns time in seconds from script start (with high precision).

  Returns:

  - `number`
## Function ac.onAlbumCoverUpdate(callback)
Sets a callback which will be called when album cover changes.

  Parameters:

  1. `callback`: `fun(hasCover: boolean)`

  Returns:

  - `ac.Disposable`
## Function ac.mediaCurrentPeak()
Returns audio peak level for the system, for left and right channels. Careful: AC audio is also included, but
it still might be used to fake some audio visualization.

  Returns:

  - `vec2`
## Function ac.mediaNextTrack()
Switches to the next track in currently active music player (by simulating media key press).
function ac.mediaNextTrack() end
## Function ac.mediaPreviousTrack()
Switches to the previous track in currently active music player (by simulating media key press).
function ac.mediaPreviousTrack() end
## Function ac.mediaPlayPause()
Pauses or unpauses current track in currently active music player (by simulating media key press).
function ac.mediaPlayPause() end
## Function ac.getTrackDateTime()
Returns floading point number of seconds since 1970/01/01 that can be used for driving track animations in such a way that if time multiplier is set to
0 or above 1, things would still happen at normal speed, although out of sync with the clock. Ensures to keep things online as well. Currently might not
work that well with replays, futher updates will improve some edge cases.

Note: if time is still being estimated, returns 0, be sure to check for that case.

  Returns:

  - `number`
## Function ac.getSimState()
Use `ac.getSim()` instead

  Returns:

  - `ac.StateSim`
## Function ac.getUiState()
Use `ac.getUI()` instead

  Returns:

  - `ac.StateUi`
## Function ac.getCarState(index)
Use `ac.getCar()` instead. Here, index starts with 1! With `ac.getCar()` index starts with 0, to match the rest of API functions

  Parameters:

  1. `index`: `integer` 1-based index.

  Returns:

  - `ac.StateCar`
## Function ac.getSim()
Returns reference to a structure with various information about the state of Assetto Corsa. Very cheap to use.
 This is a new version with shorter name.

  Returns:

  - `ac.StateSim`
## Function ac.getSession(index)
Returns reference to a structure with various information about certain session. Very cheap to use. Note: not all data
 might be available online.

  Parameters:

  1. `index`: `integer` 0-based index.

  Returns:

  - `ac.StateSession`
## Function ac.getUI()
Returns reference to a structure with various information about the state of the UI. Very cheap to use.
This is a new version with shorter name.

Note: this information is about AC UI, not about, for example, a dynamic track texture you might be updating.

  Returns:

  - `ac.StateUi`
## Function ac.getTripleConfiguration()
Returns data regarding current triple screen configuration. If AC is not launched in triple screen mode, returns `nil` instead.

  Returns:

  - `ac.StateTriple`
## Function ac.getCar(index)
Returns reference to a structure with various information about the state of a car. Very cheap to use.
This is a new version with shorter name and 0-based indexing (to match other API functions).

Note: index starts with 0. Make sure to check result for `nil` if you’re accessing a car that might not be there. First car
with index 0 is always there.

  Parameters:

  1. `index`: `integer` 0-based index.

  Returns:

  - `ac.StateCar`
## Function ac.getVR()
Returns reference to a structure with VR-related values, like hands and head positions. Very cheap to use.

Note: currently, accurate values are available with Oculus only.

  Returns:

  - `ac.StateVr`
## Function ac.getCarPhysics(index)
Returns additional details on physics state of a car. Not available in replays or for remote cars.

Note: index starts with 0. Make sure to check result for `nil` if you’re accessing a car that might not be there. First car
with index 0 is always there.

  Parameters:

  1. `index`: `integer` 0-based index.

  Returns:

  - `ac.StateCarPhysics`
## Function ac.getDualSense(gamepadIndex)
Returns extras of PS5 DualSense gamepad, such as accelerometer, gyroscope or battery state. Accelerometer and gyroscope values might be different from values reported by `ac.getDualShock()` for different controllers in the same orientation.
Note: if you’re writing a car script, first argument will be ignored and instead the effect would be applied to gamepad controlling the car if possible.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 4 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  Returns:

  - `ac.StateDualsense`
## Function ac.setDualSense(gamepadIndex, priority, holdFor)
Returns a structure with state of PS5 DualSense LEDs, change it to alter its state. Changes remain for some time, keep calling it for continuos adjustments.
Note: if you’re writing a car script, first argument will be ignored and instead the effect would be applied to gamepad controlling the car if possible.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 4 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  2. `priority`: `number?` If multiple scripts try to set LEDs at the same time, the call with highest priority will be applied. Default value: 0.

  3. `holdFor`: `number?` Time to keep the changes for in seconds. Default value: 0.5.

  Returns:

  - `ac.StateDualsenseOutput` Returns `nil` if there is no applicable controller, make sure to check for it.
## Function ac.getDualShock(gamepadIndex)
Returns extras of PS4 DualShock gamepad (or Nintendo gamepads), such as accelerometer, gyroscope or battery state. Accelerometer and gyroscope values might be different from values reported by `ac.getDualSense()` for different controllers in the same orientation.
Note: if you’re writing a car script, first argument will be ignored and instead the effect would be applied to gamepad controlling the car if possible.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 4 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  Returns:

  - `ac.StateDualshock`
## Function ac.setDualShock(gamepadIndex, priority, holdFor)
Returns a structure with state of PS4 DualShock (or Nintendo) LEDs, change it to alter its state. Changes remain for some time, keep calling it for continuos adjustments.
Note: if you’re writing a car script, first argument will be ignored and instead the effect would be applied to gamepad controlling the car if possible.

  Parameters:

  1. `gamepadIndex`: `integer` 0-based index, from 4 to 7 (first four are regular gamepads, second four are Dual Shock controllers).

  2. `priority`: `number?` If multiple scripts try to set LEDs at the same time, the call with highest priority will be applied. Default value: 0.

  3. `holdFor`: `number?` Time to keep the changes for in seconds. Default value: 0.5.

  Returns:

  - `ac.StateDualshockOutput` Returns `nil` if there is no applicable controller, make sure to check for it.
## Function web.loadRemoteModel(url, callback)
Loads a ZIP file from a given URL, unpacks first KN5 from it to a cache folder and returns
its filename through a callback. If file is already in cache storage, doesn’t do anything and
simply returns filename to it. After callback is called, that filename could be used to load
KN5 in the scene.

If there is a VAO patch in a ZIP file, it will be extracted next to KN5.

Note: only valid KN5 files and VAO patches are supported. Heavy caching is applied: if model was
downloaded once, it would not be re-downloaded (unlike with remote textures where proper HTTP caching
rules apply). If model was not accessed for a couple of weeks, it’ll be removed.

If you need to download several entities and do something afterwards, it might help to use some
promise Lua library.

Use `ac.loadRemoteAssets()` instead.

  Parameters:

  1. `url`: `string` URL to download.

  2. `callback`: `fun(err: string, filename: string)`
## Function web.loadRemoteAnimation(url, callback)
Loads a ZIP file from a given URL, unpacks first KsAnim from it to a cache folder and returns
its filename through a callback. If file is already in cache storage, doesn’t do anything and
simply returns filename to it. After callback is called, that filename could be used to animate
objects in the scene. If animation was not accessed for a couple of weeks, it’ll be removed.

If you need to download several entities and do something afterwards, it might help to use some
promise Lua library.

Use `ac.loadRemoteAssets()` instead.

  Parameters:

  1. `url`: `string` URL to download.

  2. `callback`: `fun(err: string, filename: string)`
## Function web.loadRemoteAssets(url, callback)
Loads a ZIP file from a given URL, unpacks assets from it to a cache folder and returns
path to the folder in a callback. If files are already in cache storage, doesn’t do anything and
simply returns the path. After callback is called, you can use path to the folder to get full paths to those assets.
If assets are not accessed for a couple of weeks, they’ll be removed.

  Parameters:

  1. `url`: `string` URL to download.

  2. `callback`: `fun(err: string, folder: string)`
## Function web.encryptKey(key)

  Parameters:

  1. `key`: `string`

  Returns:

  - `string`
## Class ac.StateWheel
## Class ac.StateCar
## Class ac.StateSession
## Class ac.StateWheelPhysics
## Class ac.StateWingPhysics
## Class ac.StateCarPhysics
## Class ac.StateSim
## Class ac.StateUi
## Class ac.StateTripleItem
## Class ac.StateTriple
## Class ac.StateVrHand
## Class ac.StateVr
## Class ac.StateDualsenseTouch
## Class ac.StateDualsense
## Class ac.StateDualsenseOutput
## Class ac.StateDualshockTouch
## Class ac.StateDualshock
## Class ac.StateDualshockOutput
## Function ac.getCarPosition()

  Returns:

  - `vec3`
## Function ac.getCarDirection()

  Returns:

  - `vec3`
## Function ac.getCarUp()

  Returns:

  - `vec3`
## Function ac.getCarVelocity()

  Returns:

  - `vec3`
## Function ac.getCarAngularVelocity()

  Returns:

  - `vec3`
## Function ac.getCarLocalVelocity()

  Returns:

  - `vec3`
## Function ac.getCarLocalAngularVelocity()

  Returns:

  - `vec3`
## Function ac.getCarGForces()

  Returns:

  - `vec3`
## Function ac.isGearGrinding()

  Returns:

  - `boolean`
## Function ac.getTurboBoost()

  Returns:

  - `number`
## Function ac.getEngineLifeLeft()

  Returns:

  - `number`
## Function ac.getCGHeight()

  Returns:

  - `number`
## Function ac.getTyreSlip(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `number`
## Function ac.getTyreSlipRatio(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `number`
## Function ac.getTyreSlipAngle(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `number`
## Function ac.getTyreAngularSpeed(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `number`
## Function ac.getTyreContactPoint(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `vec3`
## Function ac.getTyrePosition(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `vec3`
## Function ac.getTyreDirection(tyre)

  Parameters:

  1. `tyre`: `integer`

  Returns:

  - `vec3`
## Function ac.getDamageLevel(side)

  Parameters:

  1. `side`: `integer`

  Returns:

  - `number`
## Function ac.getSteer()

  Returns:

  - `number`
## Function ac.getGas()

  Returns:

  - `number`
## Function ac.getBrake()

  Returns:

  - `number`
## Function ac.getClutch()

  Returns:

  - `number`
## Function ac.getGear()

  Returns:

  - `integer`
## Function ac.looksLeft()

  Returns:

  - `boolean`
## Function ac.looksRight()

  Returns:

  - `boolean`
## Function ac.looksBehind()

  Returns:

  - `boolean`
## Function ac.loadSoundbank(soundbank, guids)
Loads FMOD soundbank. After soundbank is loaded, new audio events can be created which would refer to
events in the soundbank. If soundbank is missing, new audio events can still be created, but they won’t be
valid. If second parameter is missing, “GUIDs.txt” in the same folder as soundbank will be loaded. Returns
true if both files were found properly. Also, if used before audio engine is initialized, it would postpone
loading until that happens (function returns straight away, and you can create new audio events straight
away, but they would only become valid after audio initialization is complete).

  Parameters:

  1. `soundbank`: `string` Path to “.bank” file, could be absolute or relative to Lua script folder.

  2. `guids`: `string|nil` Path to “.txt” file with GUIDs, if missing, “GUIDs.txt” from soundbank folder will be used. Default value: `nil`.

  Returns:

  - `boolean` Returns `true` if both files were found.
## Function ac.isAudioReady()
Checks if audio engine is initialized and ready to work. Until then, all created audio events would return `false`
in their `:isValid()` methods, it doesn’t mean that there is a problem with soundbank (yet).

  Returns:

  - `boolean`
## Function ac.setAudioEventMultiplier(surfaceWav, mult)

  Parameters:

  1. `surfaceWav`: `string`

  2. `mult`: `number`

  Returns:

  - `boolean`
## Function ac.getRealTrackHeadingAngle()

  Returns:

  - `number`
## Function ac.getTimeZoneOffset()

  Returns:

  - `number`
## Function ac.getTimeZoneDstOffset()

  Returns:

  - `number`
## Function ac.getTimeZoneBaseOffset()

  Returns:

  - `number`
## Function ac.getConditionsSet()

  Returns:

  - `ac.ConditionsSet`
## Function ac.getConditionsSetTo(r)

  Parameters:

  1. `r`: `ac.ConditionsSet`

# Module common/const.lua

## Function const(value)
Does nothing, but with preprocessing optimizations inlines value as constant.

  Parameters:

  1. `value`: `T`

  Returns:

  - `T`

# Module common/ac_smoothing.lua

## Function smoothing.setDT(dt)
Call it once every frame at the beginning, it would affect all instances of `smoothing`.

  Parameters:

  1. `dt`: `number` Time passed since last frame, in seconds.
## Function smoothing(initialValue, smoothingIntensity)
Strange thing which is only kept for backwards compatibility. Holds a value, numerical or a vector, and
updates it every frame slowly moving it towards target value. For new projects, I would recommend to use
something else.

It doesn’t even use lag parameter, but instead some strange “smooth” thing…

  Parameters:

  1. `initialValue`: `number|vec2|vec3|vec4`

  2. `smoothingIntensity`: `number?` Default value: 100.

  Returns:

  - `smoothing`
## Class smoothing
Strange thing which is only kept for backwards compatibility. Holds a value, numerical or a vector, and
updates it every frame slowly moving it towards target value. For new projects, I would recommend to use
something else.

It doesn’t even use lag parameter, but instead some strange “smooth” thing…

- `smoothing.setDT(dt)`

  Call it once every frame at the beginning, it would affect all instances of `smoothing`.

  Parameters:

    1. `dt`: `number` Time passed since last frame, in seconds.

- `smoothing:update(newValue)`

  Updates value, moving it closer to `newValue`.

  Parameters:

    1. `newValue`: `number|vec2|vec3|vec4` Target value to move to.

- `smoothing:updateIfNew(newValue)`

  Updates value, moving it closer to `newValue`, but only if `newValue` is different from the one used in
`:updateIfNew()` last time. And for vectors it compares not by value, but by reference. Makes me wonder what was I
thinking about.

  Parameters:

    1. `newValue`: `number|vec2|vec3|vec4` Target value to move to.

# Module common/ac_matrices.lua

## Function mat3x3.identity()
Creates a new neutral matrix.

  Returns:

  - `mat3x3`
## Function mat3x3(row1, row2, row3)

  Parameters:

  1. `row1`: `vec3?`

  2. `row2`: `vec3?`

  3. `row3`: `vec3?`

  Returns:

  - `mat3x3`
## Class mat3x3

- `mat3x3.identity()`

  Creates a new neutral matrix.

  Returns:

    - `mat3x3`

- `mat3x3:set(value)`

  Parameters:

    1. `value`: `mat3x3`

  Returns:

    - `mat3x3`

- `mat3x3:clone()`

  Returns:

    - `mat3x3`
## Function mat4x4.identity()
Creates a new neutral matrix.

  Returns:

  - `mat4x4`
## Function mat4x4.translation(offset)
Creates a translation matrix.

  Parameters:

  1. `offset`: `vec3`

  Returns:

  - `mat4x4`
## Function mat4x4.rotation(angle, axis)
Creates a rotation matrix.

  Parameters:

  1. `angle`: `number` Angle in radians.

  2. `axis`: `vec3`

  Returns:

  - `mat4x4`
## Function mat4x4.euler(head, pitch, roll)
Creates a rotation matrix from Euler angles in radians.

  Parameters:

  1. `head`: `number`

  2. `pitch`: `number`

  3. `roll`: `number`

  Returns:

  - `mat4x4`
## Function mat4x4.scaling(scale)
Creates a scaling matrix.

  Parameters:

  1. `scale`: `vec3`

  Returns:

  - `mat4x4`
## Function mat4x4(row1, row2, row3, row4)

  Parameters:

  1. `row1`: `vec4?`

  2. `row2`: `vec4?`

  3. `row3`: `vec4?`

  4. `row4`: `vec4?`

  Returns:

  - `mat4x4`
## Class mat4x4

- `mat4x4.identity()`

  Creates a new neutral matrix.

  Returns:

    - `mat4x4`

- `mat4x4.translation(offset)`

  Creates a translation matrix.

  Parameters:

    1. `offset`: `vec3`

  Returns:

    - `mat4x4`

- `mat4x4.rotation(angle, axis)`

  Creates a rotation matrix.

  Parameters:

    1. `angle`: `number` Angle in radians.

    2. `axis`: `vec3`

  Returns:

    - `mat4x4`

- `mat4x4.euler(head, pitch, roll)`

  Creates a rotation matrix from Euler angles in radians.

  Parameters:

    1. `head`: `number`

    2. `pitch`: `number`

    3. `roll`: `number`

  Returns:

    - `mat4x4`

- `mat4x4.scaling(scale)`

  Creates a scaling matrix.

  Parameters:

    1. `scale`: `vec3`

  Returns:

    - `mat4x4`

- `mat4x4:set(value)`

  Parameters:

    1. `value`: `mat4x4`

  Returns:

    - `mat4x4`

- `mat4x4:transformVectorTo(destination, vec)`

  Parameters:

    1. `destination`: `vec3`

    2. `vec`: `vec3`

  Returns:

    - `vec3`

- `mat4x4:transformVector(vec)`

  Parameters:

    1. `vec`: `vec3`

  Returns:

    - `vec3`

- `mat4x4:transformPointTo(destination, vec)`

  Parameters:

    1. `destination`: `vec3`

    2. `vec`: `vec3`

  Returns:

    - `vec3`

- `mat4x4:transformPoint(vec)`

  Parameters:

    1. `vec`: `vec3`

  Returns:

    - `vec3`

- `mat4x4:clone()`

  Returns:

    - `mat4x4`

- `mat4x4:inverse()`

  Creates a new matrix.

  Returns:

    - `mat4x4`

- `mat4x4:inverseSelf()`

  Modifies current matrix.

  Returns:

    - `mat4x4` Returns self for easy chaining.

- `mat4x4:transpose()`

  Creates a new matrix.

  Returns:

    - `mat4x4`

- `mat4x4:transposeSelf()`

  Modifies current matrix.

  Returns:

    - `mat4x4` Returns self for easy chaining.

- `mat4x4:mul(other)`

  Note: unlike vector’s `:mul()`, this one creates a new matrix!

  Parameters:

    1. `other`: `mat4x4`

  Returns:

    - `mat4x4`

- `mat4x4:mulSelf(other)`

  Modifies current matrix.

  Parameters:

    1. `other`: `mat4x4`

  Returns:

    - `mat4x4` Returns self for easy chaining.

# Module common/math.lua

## Function math.gaussianAdjustment(x, k)
Takes value with even 0…1 distribution and remaps it to recreate a distribution
similar to Gaussian’s one (with k≈0.52, a default value). Lower to make bell more
compact, use a value above 1 to get some sort of inverse distibution.

  Parameters:

  1. `x`: `number` Value to adjust.

  2. `k`: `number` Bell curvature parameter.

  Returns:

  - `number`
## Function math.poissonSamplerSquare(size, tileMode)
Builds a list of points arranged in a square with poisson distribution.

  Parameters:

  1. `size`: `integer` Number of points.

  2. `tileMode`: `boolean?` If set to `true`, resulting points would be tilable without breaking poisson distribution.

  Returns:

  - `vec2`
## Function math.poissonSamplerCircle(size)
Builds a list of points arranged in a circle with poisson distribution.

  Parameters:

  1. `size`: `integer` Number of points.

  Returns:

  - `vec2`
## Function math.randomKey()
Generates a random number in [0, INT32_MAX) range. Can be a good argument for `math.randomseed()`.

  Returns:

  - `integer`
## Function math.seededRandom(seed)
Generates random number based on a seed.

  Parameters:

  1. `seed`: `integer|boolean|string` Seed.

  Returns:

  - `number` Random number from 0 to 1.
## Function math.round(number, decimals)
Rounds number, leaves certain number of decimals.

  Parameters:

  1. `number`: `number`

  2. `decimals`: `number?` Default value: 0 (rounding to a whole number).
## Function math.clampN(value, min, max)
Clamps a number value between `min` and `max`.

  Parameters:

  1. `value`: `number`

  2. `min`: `number`

  3. `max`: `number`

  Returns:

  - `number`
## Function math.saturateN(value)
Clamps a number value between 0 and 1.

  Parameters:

  1. `value`: `number`

  Returns:

  - `number`
## Function math.clampV(value, min, max)
Clamps a copy of a vector between `min` and `max`. To avoid making copies, use `vec:clamp(min, max)`.

  Parameters:

  1. `value`: `T`

  2. `min`: `any`

  3. `max`: `any`

  Returns:

  - `T`
## Function math.saturateV(value)
Clamps a copy of a vector between 0 and 1. To avoid making copies, use `vec:saturate()`.

  Parameters:

  1. `value`: `T`

  Returns:

  - `T`
## Function math.clamp(x, min, max)
Clamps value between `min` and `max`, returning `min` if `x` is below `min` or `max` if `x` is above `max`. Universal version, so might be slower.
Also, if given a vector or a color, would make a copy of it.

  Parameters:

  1. `x`: `T`

  2. `min`: `any`

  3. `max`: `any`

  Returns:

  - `T`
## Function math.saturate(x)
Clamps value between 0 and 1, returning 0 if `x` is below 0 or 1 if `x` is above 1. Universal version, so might be slower.
Also, if given a vector or a color, would make a copy of it.

  Parameters:

  1. `x`: `T`

  Returns:

  - `T`
## Function math.sign(x)
Returns a sing of a value, or 0 if value is 0.

  Parameters:

  1. `x`: `number`

  Returns:

  - `integer`
## Function math.lerp(x, y, mix)
Linear interpolation between `x` and `y` using `mix` (x * (1 - mix) + y * mix).

  Parameters:

  1. `x`: `number`

  2. `y`: `number`

  3. `mix`: `number`

  Returns:

  - `number`
## Function math.lerpInvSat(value, min, max)
Returns 0 if value is less than v0, returns 1 if it’s more than v1, linear interpolation in-between.

  Parameters:

  1. `value`: `number`

  2. `min`: `number`

  3. `max`: `number`

  Returns:

  - `number`
## Function math.smoothstep(x)
Smoothstep operation. More about it in [wiki](https://en.wikipedia.org/wiki/Smoothstep).

  Parameters:

  1. `x`: `number`

  Returns:

  - `number`
## Function math.smootherstep(x)
Like a smoothstep operation, but even smoother.

  Parameters:

  1. `x`: `number`

  Returns:

  - `number`
## Function math.normalize(x)
Creates a copy of a vector and normalizes it. Consider avoiding making a copy with `vec:normalize()`.

  Parameters:

  1. `x`: `T`

  Returns:

  - `T`
## Function math.cross(x, y)
Creates a copy of a vector and runs a cross product on it. Consider avoiding making a copy with `vec:cross(otherVec)`.

  Parameters:

  1. `x`: `vec3`

  Returns:

  - `vec3`
## Function math.dot(x, y)
Calculates dot product of two vectors.

  Parameters:

  1. `x`: `vec2|vec3|vec4`

  Returns:

  - `number`
## Function math.angle(x, y)
Calculates angle between vectors in radians.

  Parameters:

  1. `x`: `vec2|vec3|vec4`

  Returns:

  - `number` Radians.
## Function math.distance(x, y)
Calculates distance between vectors.

  Parameters:

  1. `x`: `vec2|vec3|vec4`

  Returns:

  - `number`
## Function math.distanceSquared(x, y)
Calculates squared distance between vectors (slightly faster without taking a square root).

  Parameters:

  1. `x`: `vec2|vec3|vec4`

  Returns:

  - `number`
## Function math.project(x, y)
Creates a copy of a vector and projects it onto a different vector. Consider avoiding making a copy with `vec:project(otherVec)`.

  Parameters:

  1. `x`: `T`

  Returns:

  - `T`
## Function math.isNaN(x)
Checks if value is NaN.

  Parameters:

  1. `x`: `number`

  Returns:

  - `boolean`
## Function math.lagMult(lag, dt)

  Parameters:

  1. `lag`: `number`

  2. `dt`: `number`

  Returns:

  - `number`
## Function math.applyLag(value, target, lag, dt)

  Parameters:

  1. `value`: `number`

  2. `target`: `number`

  3. `lag`: `number`

  4. `dt`: `number`

  Returns:

  - `number`

# Module common/string.lua

## Function string.split(self, separator, limit, trimResult, skipEmpty, splitByAnyChar)
Splits string into an array using separator.

  Parameters:

  1. `self`: `string` String to split.

  2. `separator`: `string?` Separator. If empty, string will be split into individual characters. Default value: ` `.

  3. `limit`: `integer?` Limit for pieces of string. Once reached, remaining string is put as a list piece.

  4. `trimResult`: `boolean?` Set to `true` to trim found strings. Default value: `false`.

  5. `skipEmpty`: `boolean?` Set to `false` to keep empty strings. Default value: `true` (for compatibility reasons).

  6. `splitByAnyChar`: `boolean?` Set to `true` to split not by a string `separator`, but by any characters in `separator`.

  Returns:

  - `string`
## Function string.numbers(self, limit)
Splits string into a bunch of numbers (not in an array). Any symbol that isn’t a valid part of number is considered to be a delimiter. Does not create an array
to keep things faster. To make it into an array, simply wrap the call in `{}`.

  Parameters:

  1. `self`: `string` String to split.

  2. `limit`: `integer?` Limit for amount of numbers. Once reached, remaining part is ignored.

  Returns:

  - `...` Numbers
## Function string.startsWith(self, another, offset)
Checks if the beginning of a string matches another string. If string to match is longer than the first one, always returns `false`.

  Parameters:

  1. `self`: `string` String to check the beginning of.

  2. `another`: `string` String to match.

  3. `offset`: `integer?` Optional offset for the matching beginning. Default value: `0`.

  Returns:

  - `boolean`
## Function string.endsWith(self, another, offset)
Checks if the end of a string matches another string. If string to match is longer than the first one, always returns `false`.

  Parameters:

  1. `self`: `string` String to check the end of.

  2. `another`: `string` String to match.

  3. `offset`: `integer?` Optional offset for the matching end. Default value: `0`.

  Returns:

  - `boolean`
## Function string.alphanumCompare(self, another)
Compares string alphanumerically.

  Parameters:

  1. `self`: `string` First string.

  2. `another`: `string` Second string.

  Returns:

  - `integer` Returns positive number if first string is larger than second one, or 0 if strings are equal.
## Function string.trim(self, characters, direction)
Trims string at beginning and end.

  Parameters:

  1. `self`: `string` String to trim.

  2. `characters`: `string?` Characters to remove. Default value: `'\n\r\t '`.

  3. `direction`: `integer?` Direction to trim, 0 for trimming both ends, -1 for trimming beginning only, 1 for trimming the end. Default value: `0`.

  Returns:

  - `string`
## Function string.multiply(self, count)
Repeats string a given number of times (`repeat` is a reserved keyword, so here we are).

  Parameters:

  1. `self`: `string` String to trim.

  2. `count`: `integer` Number of times to repeat the string.

  Returns:

  - `string`
## Function string.pad(self, targetLength, pad, direction)
Pads string with symbols from `pad` until it reaches the desired length.

  Parameters:

  1. `self`: `string` String to trim.

  2. `targetLength`: `integer` Desired string length. If shorter than current length, string will be trimmed from the end.

  3. `pad`: `string?` String to pad with. If empty, no padding will be performed. If has more than one symbol, will be repeated to fill the space. Default value: ` ` (space).

  4. `direction`: `integer?` Direction to pad to, 1 for padding at the end, -1 for padding at the start, 0 for padding from both ends centering string. Default value: `1`.

  Returns:

  - `string`
## Function string.regfind(self, pattern, init, ignoreCase)
Similar to `string.find()`: looks for the first match of `pattern` and returns indices, but uses regular expressions.

Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.

  Parameters:

  1. `self`: `string` String to search in.

  2. `pattern`: `string` Regular expression.

  3. `init`: `integer?` 1-based offset to start searching from. Default value: `1`.

  4. `ignoreCase`: `boolean?` Set to `true` to make search case-insensitive. Default value: `false`.

  Returns:

  1. `integer`

  2. `integer` 1-based index of the ending of found pattern, or `nil` if no match has been found.

  3. `...` Captured elements, if there are any capture groups in the pattern.
## Function string.regmatch(self, pattern, init, ignoreCase)
Similar to `string.match()`: looks for the first match of `pattern` and returns matches, but uses regular expressions.

Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.

  Parameters:

  1. `self`: `string` String to search in.

  2. `pattern`: `string` Regular expression.

  3. `init`: `integer?` 1-based offset to start searching from. Default value: `1`.

  4. `ignoreCase`: `boolean?` Set to `true` to make search case-insensitive. Default value: `false`.

  Returns:

  - `string` Captured elements if there are any capture groups in the pattern, or the whole captured string otherwise.
## Function string.reggmatch(self, pattern, ignoreCase)
Similar to `string.gmatch()`: iterates over matches of `pattern`, but uses regular expressions.

Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.

  Parameters:

  1. `self`: `string` String to search in.

  2. `pattern`: `string` Regular expression.

  3. `ignoreCase`: `boolean?` Set to `true` to make search case-insensitive. Default value: `false`.

  Returns:

  - `fun`
## Function string.reggsub(self, pattern, repl, ignoreCase)
Similar to `string.gsub()`: replaces all entries of `pattern` with `repl`, but uses regular expressions.

Note: regular expressions currently are in ECMAScript format, so backtracking is not supported. Also, in most cases they are slower than regular Lua patterns.

  Parameters:

  1. `self`: `string` String to search in.

  2. `pattern`: `string` Regular expression.

  3. `ignoreCase`: `boolean?` Set to `true` to make search case-insensitive. Default value: `false`.

  Returns:

  - `string` String with found entries replaced.

# Module common/table.lua

## Function table.chain(table, ...)
Merges tables into one big table. Tables can be arrays or dictionaries, if it’s a dictionary same keys from subsequent tables will overwrite previously set keys.

  Parameters:

  1. `table`: `T`

  Returns:

  - `T`
## Function table.isArray(t)
Checks if table is an array or not. Arrays are tables that only have consequtive numeric keys.

  Parameters:

  1. `t`: `table|any[]`

  Returns:

  - `boolean`
## Function table.new(arrayElements, mapElements)
Creates a new table with preallocated space for given amount of elements.

  Parameters:

  1. `arrayElements`: `integer` How many elements the table will have as a sequence.

  2. `mapElements`: `integer` How many other elements the table will have.

  Returns:

  - `table`
## Function table.clear(t)
Cleares table without deallocating space using a fast LuaJIT call. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table`
## Function table.nkeys(t)
Returns the total number of elements in a given Lua table (i.e. from both the array and hash parts combined).

  Parameters:

  1. `t`: `table`
## Function table.clone(t, deep)
Clones table using a fast LuaJIT call.

  Parameters:

  1. `t`: `table`

  2. `deep`: `boolean|`true`|`false`` Set to `true` for deep cloning.
## Function table.removeItem(t, item)
Removes first item by value, returns true if any item was removed. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table<any, T>`

  2. `item`: `T`

  Returns:

  - `boolean`
## Function table.getOrCreate(t, key, callback, callbackData)
Returns an element from table with a given key. If there is no such element, calls callback
and uses its return value to add a new element and return that. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table<any, T>`

  2. `key`: `any`

  3. `callback`: `fun(callbackData: TCallbackData): T`

  4. `callbackData`: `TCallbackData?`

  Returns:

  - `T`
## Function table.contains(t, item)
Returns true if table contains an item. Can work with both array and non-array tables.

  Parameters:

  1. `t`: `table<any, T>`

  2. `item`: `T`

  Returns:

  - `boolean`
## Function table.random(t, filteringCallback, filteringCallbackData, randomDevice)
Returns a random item from a table. Optional callback works like a filter. Can work
with both array and non-array tables. Alternatively, optional callback can provide a number
for a weight of an item.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `filteringCallback`: `nil|fun(item: T, key: TKey, callbackData: TCallbackData): boolean`

  3. `filteringCallbackData`: `TCallbackData?`

  4. `randomDevice`: `nil|fun(): number` Optional callback for generating random numbers. Needs to return a value between 0 and 1. If not set, default `math.random` is used.

  Returns:

  - `T`
## Function table.indexOf(t, item)
Returns a key of a given element, or `nil` if there is no such element in a table. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `item`: `T`

  Returns:

  - `TKey|nil`
## Function table.join(t, itemsJoin, keyValueJoin, toStringCallback, toStringCallbackData)
Joins elements of a table to a string, works with both arrays and non-array tables. Optinal
toStringCallback parameter can be used for a custom item serialization. All parameters but
`t` (for actual table) are optional and can be skipped.

Note: it wouldn’t work as fast as `table.concat`, but it would call a `tostring()` (or custom
serializer callback) for each element.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `itemsJoin`: `string?` Default value: ','.

  3. `keyValueJoin`: `string?` Default value: '='.

  4. `toStringCallback`: `nil|fun(item: T, key: TKey, callbackData: TCallbackData): string`

  5. `toStringCallbackData`: `TCallbackData?`

  Returns:

  - `TKey|nil`
## Function table.slice(t, from, to, step)
Slices array, basically acts like slicing thing in Python.

  Parameters:

  1. `t`: `T[]`

  2. `from`: `integer` Starting index.

  3. `to`: `integer?` Ending index.

  4. `step`: `integer?` Step.

  Returns:

  - `T`
## Function table.reverse(t)
Flips table from back to front, requires an array.

  Parameters:

  1. `t`: `T[]`

  Returns:

  - `T`
## Function table.map(t, callback, callbackData)
Calls callback function for each of table elements, creates a new table containing all the resulting values.
Can work with both array and non-array tables. For non-array tables, new table is going to be an array unless
callback function would return a key as a second return value.

If callback returns two values, second would be used as a key to create a table-like table (not an array-like one).

Note: if callback returns `nil`, value will be skipped, so this function can act as a filtering one too.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): TReturnValue, TReturnKey|nil` Mapping callback.

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `table`
## Function table.reduce(t, startingValue, callback, callbackData)
Calls callback function for each of table elements, creates a new table containing all the resulting values.
Can work with both array and non-array tables. For non-array tables, new table is going to be an array unless
callback function would return a key as a second return value.

If callback returns two values, second would be used as a key to create a table-like table (not an array-like one).

Note: if callback returns `nil`, value will be skipped, so this function can act as a filtering one too.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `startingValue`: `TData`

  3. `callback`: `fun(data: TData, item: T, index: TKey, callbackData: TCallbackData): TData` Reduction callback.

  4. `callbackData`: `TCallbackData?`

  Returns:

  - `TData`
## Function table.filter(t, callback, callbackData)
Creates a new table from all elements for which filtering callback returns true. Can work with both
array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): any` Filtering callback.

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `table`
## Function table.every(t, callback, callbackData)
Returns true if callback returns non-false value for every element of the table. Can work with both
array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): boolean`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `boolean`
## Function table.some(t, callback, callbackData)
Returns true if callback returns non-false value for at least a single element of the table. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): boolean`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `boolean`
## Function table.count(t, callback, callbackData)
Counts number of elements for which callback returns non-false value. Can work
with both array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): boolean`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `integer`
## Function table.sum(t, callback, callbackData)
Calls callback for each element, returns sum of returned values. Can work
with both array and non-array tables. If callback is missing, sums actual values in table.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): boolean`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `integer`
## Function table.findFirst(t, callback, callbackData)
Returns first element and its key for which callback returns a non-false value. Can work
with both array and non-array tables. If nothing is found, returns `nil`.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): boolean`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `T`
## Function table.findByProperty(t, key, value)
Returns first element and its key for which a certain property matches the value. If nothing is
found, returns `nil`.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `key`: `string`

  3. `value`: `any`

  Returns:

  - `T`
## Function table.maxEntry(t, callback, callbackData)
Returns an element and its key for which callback would return the highest numerical value. Can work
with both array and non-array tables. If callback is missing, actual table elements will be compared.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): number`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `T`
## Function table.minEntry(t, callback, callbackData)
Returns an element and its key for which callback would return the lowest numerical value. Can work
with both array and non-array tables. If callback is missing, actual table elements will be compared.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, index: TKey, callbackData: TCallbackData): number`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `T`
## Function table.forEach(t, callback, callbackData)
Runs callback for each item in a table. Can work with both array and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `fun(item: T, key: TKey, callbackData: TCallbackData)`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `table`
## Function table.distinct(t, callback, callbackData)
Creates a new table with unique elements from original table only. Optionally, a callback
can be used to provide a key which uniqueness will be checked. Can work with both array
and non-array tables.

  Parameters:

  1. `t`: `table<TKey, T>`

  2. `callback`: `nil|fun(item: T, key: TKey, callbackData: TCallbackData): any`

  3. `callbackData`: `TCallbackData?`

  Returns:

  - `table`
## Function table.findLeftOfIndex(t, testCallback, testCallbackData)
Finds first element for which `testCallback` returns true, returns index of an element before it.
Elements should be ordered in such a way that there would be no more elements returning false to the right
of an element returning true.

If `testCallback` returns true for all elements, would return 0. If `testCallback` returns false for all,
returns index of the latest element.

  Parameters:

  1. `t`: `T[]`

  2. `testCallback`: `fun(item: T, index: integer, callbackData: TCallbackData): boolean`

  3. `testCallbackData`: `nil|TCallbackData`

  Returns:

  - `integer`
## Function table.assign(target, ...)
Similar to JavaScript’s `Object.assign()`, works with tables and arrays, returns first argument (modified).

  Parameters:

  1. `target`: `T`

  2. `...`: `table`

  Returns:

  - `T`
## Function table.flatten(t, maxLevel)
Flattens table similar to JavaScript function with the same name. Requires an array.

  Parameters:

  1. `t`: `any[]`

  2. `maxLevel`: `integer?` Default value: 1.

  Returns:

  - `any`
## Function table.range(endingIndex, startingIndex, step, callback, callbackData)
Creates a new table running in steps from `startingIndex` to `endingIndex`, including `endingIndex`.
If callback returns two values, second value is used as a key.

  Parameters:

  1. `endingIndex`: `integer?`

  2. `startingIndex`: `integer`

  3. `step`: `integer?`

  4. `callback`: `fun(index: integer, callbackData: TCallbackData): T, integer|string?`

  5. `callbackData`: `TCallbackData?`

  Returns:

  - `T`
## Function table.build(iterator, k, v)
Creates a new table from iterator. Supports iterators returning one or two values (if two values are returned, first is considered the key,
if not, values are simply added to a list).

  Parameters:

  1. `iterator`: `fun(...): T`

  Returns:

  - `T`

# Module common/io.lua

## Class io.FileAttributes
Structure containing various file or directory attributes, including various flags and dates. All values are precomputed and ready to be used (there is
no overhead in accessing them once you get the structure).
## Function io.load(filename, fallbackData)
Reads file content into a string, if such file exists, otherwise returns fallback data or `nil`.

  Parameters:

  1. `filename`: `string` Filename.

  2. `fallbackData`: `string|nil` Data to return if file could not be read.

  Returns:

  - `string|nil` Returns `nil` if file couldn’t be read and there is no fallback data.
## Function io.scanDir(directory, mask, callback, callbackData)
Scan directory and call callback function for each of files, passing file name (not full name, but only name of the file) and attributes. If callback function would return
a non-nil value, iteration will stop and value returned by callback would return from this function. This could be used to
find a certain file without going through all files in the directory. Optionally, a mask can be used to pre-filter received files
entries.

If callback function is not provided, it’ll return list of files instead (file names only).

System entries “.” and “..” will not be included in the list of files. Accessing attributes does not add extra cost.

  Parameters:

  1. `directory`: `string` Directory to look for files in. Note: directory is relative to current directory, not to script directory. For AC in general it’s an AC root directory, but do not rely on it, instead use `ac.getFolder(ac.FolderID.Root)`.

  2. `mask`: `string?` Mask in a form of usual “*.*”. Default value: '*'.

  3. `callback`: `fun(fileName: string, fileAttributes: io.FileAttributes, callbackData: TCallbackData): TReturn` Callback which will be ran for every file in directory fitting mask until it would return a non-nil value.

  4. `callbackData`: `TCallbackData?` Callback data that will be passed to callback as third argument, to avoid creating a capture.

  Returns:

  - `TReturn` First non-nil value returned by callback.
## Function io.scanDrives()
Returns list of logical drives, each drive in “A:“ format.

  Returns:

  - `string`
## Function io.scanZip(filename)
Returns list of entry names from a ZIP-file.

  Parameters:

  1. `filename`: `string`

  Returns:

  - `string`

# Module common/os.lua

## Class os.ConsoleProcessResult
## Function os.openFileDialog(params, callback)
Opens regular Windows file opening dialog, calls callback with either an error or a path to a file selected by user
(or nil if selection was cancelled). All parameters in `params` table are optional (the whole table too).

  Parameters:

  1. `params`: `{title: string, defaultFolder: string, folder: string, fileName: string, fileTypes: {` name: string, mask: string }[], addAllFilesFileType: boolean, fileTypeIndex: integer, fileNameLabel: string, okButtonLabel: string, places: string[], flags: os.DialogFlags}|"{\n  defaultFolder = ac.getFolder(ac.FolderID.Root),\n  fileTypes = {\n    {\n      name = 'Images',\n      mask = '*.png;*.jpg;*.jpeg;*.psd'\n    }\n  },\n  addAllFilesFileType = true,\n  flags = bit.bor(os.DialogFlags.PathMustExist, os.DialogFlags.FileMustExist)\n}" "Table with properties:\n- `title` (`string`): Dialog title.\n- `defaultFolder` (`string`): Default folder if there is not a recently used folder value available.\n- `folder` (`string`): Selected folder (unlike `defaultFolder`, overrides recently used folder).\n- `fileName` (`string`): File name that appears in the File name edit box when that dialog box is opened.\n- `fileTypes` (`{ name: string, mask: string }[]`): File types (names and masks).\n- `addAllFilesFileType` (`boolean`): If providing file types, set this to true to automatically add “All Files (*.*)” type at the bottom\n- `fileTypeIndex` (`integer`): File type selected by default (1-based).\n- `fileNameLabel` (`string`): Text of the label next to the file name edit box.\n- `okButtonLabel` (`string`): Text of the Open button.\n- `places` (`string[]`): Additional places to show in the list of locations on the left.\n- `flags` (`os.DialogFlags`): Dialog flags (use `bit.bor()` to combine flags together to avoid errors with adding same flag twice)"

  2. `callback`: `fun(err: string, filename: string)`
## Function os.saveFileDialog(params, callback)
Opens regular Windows file saving dialog, calls callback with either an error or a path to a file selected by user
(or nil if selection was cancelled). All parameters in `params` table are optional (the whole table too).

  Parameters:

  1. `params`: `{title: string, defaultFolder: string, defaultExtension: string, folder: string, fileName: string, saveAsItem: string, fileTypes: {` name: string, mask: string }[], addAllFilesFileType: boolean, fileTypeIndex: integer, fileNameLabel: string, okButtonLabel: string, places: string[], flags: os.DialogFlags}|"{\n  defaultFolder = ac.getFolder(ac.FolderID.Root),\n  fileTypes = {\n    {\n      name = 'Images',\n      mask = '*.png;*.jpg;*.jpeg;*.psd'\n    }\n  },\n  addAllFilesFileType = true,\n  flags = bit.bor(os.DialogFlags.PathMustExist, os.DialogFlags.OverwritePrompt, os.DialogFlags.NoReadonlyReturn)\n}" "Table with properties:\n- `title` (`string`): Dialog title.\n- `defaultFolder` (`string`): Default folder if there is not a recently used folder value available.\n- `defaultExtension` (`string`): Sets the default extension to be added to file names.\n- `folder` (`string`): Selected folder (unlike `defaultFolder`, overrides recently used folder).\n- `fileName` (`string`): File name that appears in the File name edit box when that dialog box is opened.\n- `saveAsItem` (`string`): Ann item to be used as the initial entry in a Save As dialog.\n- `fileTypes` (`{ name: string, mask: string }[]`): File types (names and masks).\n- `addAllFilesFileType` (`boolean`): If providing file types, set this to true to automatically add “All Files (*.*)” type at the bottom\n- `fileTypeIndex` (`integer`): File type selected by default (1-based).\n- `fileNameLabel` (`string`): Text of the label next to the file name edit box.\n- `okButtonLabel` (`string`): Text of the Save button.\n- `places` (`string[]`): Additional places to show in the list of locations on the left.\n- `flags` (`os.DialogFlags`): Dialog flags (use `bit.bor()` to combine flags together to avoid errors with adding same flag twice)"

  2. `callback`: `fun(err: string, filename: string)`
## Function os.runConsoleProcess(params, callback)
Run a console process in background with given arguments, return exit code and output in callback. Launched process will be tied
to AC process to shut down with AC (works only on Windows 8 and newer).

  Parameters:

  1. `params`: `{filename: string, arguments: string[], rawArguments: boolean, workingDirectory: string, timeout: integer, environment: table, inheritEnvironment: boolean, stdin: string, separateStderr: boolean, terminateWithScript: boolean, dataCallback: fun(err: boolean, data: string)}|"{` filename = '', arguments = {} }" "Table with properties:\n- `filename` (`string`): Application filename.\n- `arguments` (`string[]`): Arguments (quotes will be added automatically unless `rawArguments` is set to true).\n- `rawArguments` (`boolean`): Set to `true` to disable any arguments processing and pass them as they are, simply joining them with a space symbol.\n- `workingDirectory` (`string`): Working directory.\n- `timeout` (`integer`): Timeout in milliseconds. If above zero, process will be killed after given time has passed.\n- `environment` (`table`): If set to a table, values from that table will be used as environment variables instead of inheriting ones from AC process.\n- `inheritEnvironment` (`boolean`): Set to `true` to inherit AC environment variables before adding custom ones.\n- `stdin` (`string`): Optional data to pass to a process in stdin pipe.\n- `separateStderr` (`boolean`): Store stderr data in a separate string.\n- `terminateWithScript` (`boolean`): Terminate process if this Lua script were to terminate (for example, during reload).\n- `dataCallback` (`fun(err: boolean, data: string)`): If set to a function, data written in stdout and stderr will be passed to the function instead as it arrives."

  2. `callback`: `nil|fun(err: string, data: os.ConsoleProcessResult)`

# Module common/timer.lua

## Function setTimeout(callback, delay, uniqueKey)
Runs callback after certain time. Returns cancellation ID.
Note: all callbacks will be ran before `update()` call,
and they would only ran when script runs. So if your script is executed each frame and AC runs at 60 FPS, smallest interval
would be 0.016 s, and anything lower that you’d set would still act like 0.016 s. Also, intervals would only be called once
per frame.

  Parameters:

  1. `callback`: `fun()`

  2. `delay`: `number?` Delay time in seconds. Default value: 0.

  3. `uniqueKey`: `any?` Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.

  Returns:

  - `integer`
## Function setInterval(callback, period, uniqueKey)
Repeteadly runs callback after certain time. Returns cancellation ID.
Note: all callbacks will be ran before `update()` call,
and they would only ran when script runs. So if your script is executed each frame and AC runs at 60 FPS, smallest interval
would be 0.016 s, and anything lower that you’d set would still act like 0.016 s. Also, intervals would only be called once
per frame.

  Parameters:

  1. `callback`: `fun()`

  2. `period`: `number?` Period time in seconds. Default value: 0.

  3. `uniqueKey`: `any?` Unique key: if set, timer wouldn’t be added unless there is no more active timers with such ID.

  Returns:

  - `integer`
## Function clearTimeout(cancellationID)
Stops timeout.

  Parameters:

  1. `cancellationID`: `integer` Value earlier retuned by `setTimeout()`. If a non-numerical value is passed (like a `nil`), call is ignored and returns `false`.

  Returns:

  - `boolean` True if timeout with such ID has been found and stopped.
## Function clearInterval(cancellationID)
Stops interval.

  Parameters:

  1. `cancellationID`: `integer` Value earlier retuned by `setInterval()`.

  Returns:

  - `boolean` True if interval with such ID has been found and stopped.

# Module common/ac_extras_ini.lua

## Function ac.INIConfig(format, sections)
A wrapper for data parsed from an INI files, supports different INI formats. Parsing is done on
CSP side, rest is on CSP side. Use `:get()` and `:set()` methods to operate values.

  Parameters:

  1. `format`: `ac.INIFormat`

  2. `sections`: `table`

  Returns:

  - `ac.INIConfig`
## Class ac.INIConfig
A wrapper for data parsed from an INI files, supports different INI formats. Parsing is done on
CSP side, rest is on CSP side. Use `:get()` and `:set()` methods to operate values.

- `ac.INIConfig:get(section, key, defaultValue, offset)`

  Get value from parsed INI file. Note: getting vector values creates them anew, so if you’re going to use a value often, consider
caching it locally.

  Parameters:

    1. `section`: `string` Section name.

    2. `key`: `string` Value key.

    3. `defaultValue`: `T` Defines type of value to return, is returned if value is missing. If not set, list of strings is returned.

    4. `offset`: `integer?` Optional 1-based offset for data parsed in CSP format (in case value contains several items). Default value: 1.

  Returns:

    - `T`

- `ac.INIConfig:tryGetLut(section, key)`

  Attempts to load a 1D-to-1D LUT from an INI file, supports both inline “(|X=Y|…|)” LUTs and separate files next to configs (only
for configs loaded by filename or from car data)

  Returns:

    - `ac.DataLUT11`

- `ac.INIConfig:iterate(prefix, noPostfixForFirst)`

  Iterates over sections of INI file with a certain prefix. Order matches order of CSP parsing such data.

Example:
```lua
for index, section in iniConfig:iterate('LIGHT') do
  print('Color: '..iniConfig:get(section, 'COLOR', 'red'))
end
```

  Parameters:

    1. `prefix`: `string` Prefix for section names.

    2. `noPostfixForFirst`: `boolean?` Only for default INI format. If set to `true`, first section would not have “_0” postfix.

  Returns:

    - `fun`

- `ac.INIConfig:iterateValues(section, prefix, digitsOnly)`

  Iterates over values of INI section with a certain prefix. Order matches order of CSP parsing such data.

Example:
```lua
for index, key in iniConfig:iterateValues('LIGHT_0', 'POSITION', true) do
  print('Position: '..tostring(iniConfig:get('LIGHT_0', key, vec3())))
end
```

  Parameters:

    1. `prefix`: `string` Prefix for section names.

    2. `digitsOnly`: `boolean?` If set to `true`, would only collect keys consisting of a prefix and a number (useful for configs with extra properties).

  Returns:

    - `fun`

- `ac.INIConfig:mapSection(section, defaults)`

  Takes table with default values and returns a table with values filled from config.

  Parameters:

    1. `section`: `string` Section name.

    2. `defaults`: `T` Table with keys and default values. Keys are the same as INI keys.

  Returns:

    - `T`

- `ac.INIConfig:mapConfig(defaults)`

  Takes table with default values and returns a table with values filled from config.

  Parameters:

    1. `defaults`: `T` Table with section names and sub-tables with keys and default values. Keys are the same as INI keys.

  Returns:

    - `T`

- `ac.INIConfig:set(section, key, value)`

  Set an INI value. Pass `nil` as value to remove it.

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `value`: `string|string[]|number|boolean|nil|vec2|vec3|vec4|rgb|rgbm`

  Returns:

    - `ac.INIConfig` Returns itself for chaining several methods together.

- `ac.INIConfig:setAndSave(section, key, value)`

  Set an INI value and save file immediattely using special old Windows function to edit a single INI value. Compatible only with default
INI format. Doesn’t provide major peformance improvements, but might be useful if you prefer to keep original formatting as much as possible
when editing a single value only.

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `value`: `string|string[]|number|boolean|nil|vec2|vec3|vec4|rgb|rgbm`

  Returns:

    - `boolean` Returns `true` if new value is different and config was saved.

- `ac.INIConfig:serialize()`

  Serializes data in INI format using format specified on INIConfig creation. You can also use `tostring()` function.

  Returns:

    - `string`

- `ac.INIConfig:save(filename)`

  Saves contents to a file in INI form.

  Parameters:

    1. `filename`: `string?` Filename. If filename is not set, saves file with the same name as it was loaded. Updates `filename` field.

  Returns:

    - `ac.INIConfig` Returns itself for chaining several methods together.
## Function ac.INIConfig.parse(data, format)
Parse INI config from a string.

  Parameters:

  1. `data`: `string` Serialized INI data.

  2. `format`: `ac.INIFormat?` Format to parse. Default value: `ac.INIFormat.Default`.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.load(filename, format, includeFolders)
Load INI file, optionally with includes.

  Parameters:

  1. `filename`: `string` INI config filename.

  2. `format`: `ac.INIFormat?` Format to parse. Default value: `ac.INIFormat.Default`.

  3. `includeFolders`: `string[]?` Optional folders to include files from (only for `ac.INIFormat.ExtendedIncludes` format). If not set, parent folder for config filename is used.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.carData(carIndex, fileName)
Load car data INI file. Supports “data.acd” files as well. Returned files might be tweaked by
things like custom physics virtual tyres. To get original file, use `ac.INIConfig.load()`.

Returned file can’t be saved.

  Parameters:

  1. `carIndex`: `number` 0-based car index.

  2. `fileName`: `string` Car data file name, such as `'tyres.ini'`.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.trackData(fileName)
Load track data INI file. Can be used by track scripts which might not always  have access to those files directly.

Returned file can’t be saved.

  Parameters:

  1. `fileName`: `string` Car data file name, such as `'tyres.ini'`.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.onlineExtras()
Returns config with extra online options, the ones that can be set with Content Manager.

  Returns:

  - `ac.INIConfig|nil` If not an online session, returns `nil`.
## Function ac.INIConfig.raceConfig()
Returns race config (`cfg/race.ini`). Password and online GUID won’t be included.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.videoConfig()
Returns video config (`cfg/video.ini`).

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.cspModule(cspModuleID)
Load config of a CSP module by its name.

  Parameters:

  1. `cspModuleID`: `ac.CSPModuleID` Name of a CSP module.

  Returns:

  - `ac.INIConfig`
## Function ac.INIConfig.scriptSettings()
Load config of the current Lua script (“settings.ini” in script directory and settings overriden by user, meant to be customizable with Content Manager).

  Returns:

  - `ac.INIConfig`

# Module common/ac_extras_datalut.lua

## Function ac.DataLUT11()
Creates a new empty LUT. Use `ac.Lut:add(input, output)` to fill it with data.

  Returns:

  - `ac.DataLUT11`
## Function ac.DataLUT11.parse(data)
Parse LUT from a string in “(|X1=Y1|X2=Y2|…|)” format.

  Parameters:

  1. `data`: `string` Serialized LUT data.

  Returns:

  - `ac.DataLUT11`
## Function ac.DataLUT11.load(filename)
Load LUT file.

  Parameters:

  1. `filename`: `string` LUT filename.

  Returns:

  - `ac.DataLUT11`
## Function ac.DataLUT11.carData(carIndex, fileName)
Load car data LUT file. Supports “data.acd” files as well.

  Parameters:

  1. `carIndex`: `number` 0-based car index.

  2. `fileName`: `string` Car data file name, such as `'power.lut'`.

  Returns:

  - `ac.DataLUT11`
## Class ac.DataLUT11
Simple 1D-to-1D lookup table wrapper, helps to deal with all those “.lut“ files in car data.

- `ac.DataLUT11:add(input, output)`

  Add a new value to LUT.

  Parameters:

    1. `input`: `number`

    2. `output`: `number`

  Returns:

    - `ac.DataLUT11` Returns self for easy chaining.

- `ac.DataLUT11:bounds()`

  Returns data boundaries.

  Returns:

    1. `vec2` Minimum input and output.

    2. `vec2` Maximum input and output.

- `ac.DataLUT11:get(input)`

  Computes a LUT value using either linear or cubic interpolation (set field `ac.DataLUT11.useCubicInterpolation` to
`true` to use cubic interpolation).

  Parameters:

    1. `input`: `number`

  Returns:

    - `number`

- `ac.DataLUT11:getPointInput(index)`

  Returns input value of a certain point of a LUT, or `math.nan` if there is no such point.

  Parameters:

    1. `index`: `number` 0-based index.

  Returns:

    - `number`

- `ac.DataLUT11:getPointOutput(index)`

  Returns output value of a certain point of a LUT, or `math.nan` if there is no such point.

  Parameters:

    1. `index`: `number` 0-based index.

  Returns:

    - `number`

# Module common/ac_extras_connect.lua

## Function ac.connect(layout, keepLive, namespace)
Creates a new shared structure to quickly exchange data between different Lua scripts within a session. Example:
```lua
local sharedData = ac.connect{
  ac.StructItem.key('myChannel'),        -- optional, to avoid collisions
  someString = ac.StructItem.string(24), -- 24 is for capacity
  someInt = ac.StructItem.int(),
  someDouble = ac.StructItem.double(),
  someVec = ac.StructItem.vec3()
}
```

Note: to connect two scripts, both of them chould use `ac.connect()` and pass exactly the same layouts. Also, consider using more
specific names to avoid possible unwanted collisions. For example, instead of using `value = ac.StructItem.int()` which might be
used somewhere else, use `weatherBrightnessValue = ac.StructItem.int()`. Or, simply add `ac.StructItem.key('myUniqueKey')`.

For safety reasons, car scripts can only connect to other car scripts, and track scripts can only connect to other track scripts.

  Parameters:

  1. `layout`: `T` A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Alternatively, you can pass a string for the body of the structure here, but be careful with it.

  2. `keepLive`: `boolean?` Set to true to keep structure even if any references were removed or script was unloaded.

  3. `namespace`: `nil|ac.SharedNamespace` Optional namespace stopping scripts of certain types to access data of scripts with different types. For more details check `ac.SharedNamespace` documentation.

  Returns:

  - `T`

# Module common/ac_struct_item.lua

## Function ac.StructItem.key(key)

  Returns:

  - `nil`
## Function ac.StructItem.half()

  Returns:

  - `number`
## Function ac.StructItem.float()

  Returns:

  - `number`
## Function ac.StructItem.double()

  Returns:

  - `number`
## Function ac.StructItem.norm8()

  Returns:

  - `number`
## Function ac.StructItem.unorm8()

  Returns:

  - `number`
## Function ac.StructItem.norm16()

  Returns:

  - `number`
## Function ac.StructItem.unorm16()

  Returns:

  - `number`
## Function ac.StructItem.int16()

  Returns:

  - `integer`
## Function ac.StructItem.uint16()

  Returns:

  - `integer`
## Function ac.StructItem.int32()

  Returns:

  - `integer`
## Function ac.StructItem.uint32()

  Returns:

  - `integer`
## Function ac.StructItem.int64()

  Returns:

  - `integer`
## Function ac.StructItem.uint64()

  Returns:

  - `integer`
## Function ac.StructItem.boolean()

  Returns:

  - `boolean`
## Function ac.StructItem.char()

  Returns:

  - `integer`
## Function ac.StructItem.byte()

  Returns:

  - `integer`
## Function ac.StructItem.vec2()

  Returns:

  - `vec2`
## Function ac.StructItem.vec3()

  Returns:

  - `vec3`
## Function ac.StructItem.vec4()

  Returns:

  - `vec4`
## Function ac.StructItem.rgb()

  Returns:

  - `rgb`
## Function ac.StructItem.rgbm()

  Returns:

  - `rgbm`
## Function ac.StructItem.hsv()

  Returns:

  - `hsv`
## Function ac.StructItem.quat()

  Returns:

  - `quat`
## Function ac.StructItem.array(elementType, size)

  Parameters:

  1. `elementType`: `T`

  2. `size`: `integer`

  Returns:

  - `T`
## Function ac.StructItem.string(capacity)

  Returns:

  - `string`

# Module common/ac_extras_hashspace.lua

## Class ac.HashSpaceItem

- `ac.HashSpaceItem:id()`

  Returns ID associated with an item.

  Returns:

    - `integer`

- `ac.HashSpaceItem:update(pos)`

  Moves an item to a position.

  Parameters:

    1. `pos`: `vec3`

- `ac.HashSpaceItem:dispose()`

  Removes item from its space.
function HashSpaceItem:dispose() end
## Function ac.HashSpace(cellSize)
Simple structure meant to speed up collision detection by arranging items in a grid using hashmap. Cells are arranged horizontally.

  Parameters:

  1. `cellSize`: `number` Should be about twice as large as your largest entity.

  Returns:

  - `ac.HashSpace`
## Class ac.HashSpace
Simple structure meant to speed up collision detection by arranging items in a grid using hashmap. Cells are arranged horizontally.

- `ac.HashSpace:iterate(pos, callback, callbackData)`

  Iterates items around given position.

  Parameters:

    1. `pos`: `vec3`

    2. `callback`: `fun(id: integer, callbackData: T)`

    3. `callbackData`: `T?`

- `ac.HashSpace:anyAround(pos)`

  Checks if there are any items around given position.

  Parameters:

    1. `pos`: `vec3`

  Returns:

    - `boolean`

- `ac.HashSpace:count(pos)`

  Count amount of items around given position.

  Parameters:

    1. `pos`: `vec3`

  Returns:

    - `integer`

- `ac.HashSpace:rawPointers(pos)`

  Returns raw pointers for given position for manual iteration. Be careful!

  Parameters:

    1. `pos`: `vec3`

  Returns:

    - `any`

- `ac.HashSpace:add()`

  Adds a new dynamic item to the grid. Each item gets a new ID.

  Returns:

    - `ac.HashSpaceItem`

- `ac.HashSpace:addFixed(id, pos)`

  Adds a fixed item to the grid, with predetermined ID. Avoid mixing dynamic and fixed items in the same grid.

  Parameters:

    1. `id`: `integer`

    2. `pos`: `vec3`

# Module common/ac_extras_numlut.lua

## Function ac.Lut(data, hsvColumns)
Meant to quickly interpolate between tables of values, some of them could be colors set in HSV. Example:
```lua
local lut = ac.Lut([[
 -100 |  0.00,   350,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
  -90 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
  -20 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
]], { 2 })
assert(lut:calculate(-95)[1] == 1)
```

  Parameters:

  1. `data`: `string` String with LUT data, in a format similar to AC LUT formats. Please note: rows must be ordered for efficient binary search.

  2. `hsvColumns`: `integer[]` 1-based indices of columns storing HSV data. Such columns, of course, will be interpolated differently (for example, mixing hues 350 and 20 would produce 10).

  Returns:

  - `ac.Lut`
## Class ac.Lut
Meant to quickly interpolate between tables of values, some of them could be colors set in HSV. Example:
```lua
local lut = ac.Lut([[
 -100 |  0.00,   350,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
  -90 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
  -20 |  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04
]], { 2 })
assert(lut:calculate(-95)[1] == 1)
```

- `ac.Lut:calculate(input)`

  Interpolate for a given input, return a newly created table. Note: consider using `:calculateTo()` instead to avoid re-creating tables, it would work much more efficiently.

  Parameters:

    1. `input`: `number`

  Returns:

    - `number`

- `ac.Lut:calculateTo(output, input)`

  Interpolate for a given input, write result to a given table.

  Parameters:

    1. `output`: `number[]`

    2. `input`: `number`

  Returns:

    - `number`
## Class ac.LutJit
Meant to quickly interpolate between tables of values, some of them could be colors set in HSV. Example:
```lua
local lutJit = ac.LutJit:new{ data = {
  { input = -100, output = {  0.00,   350,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
  { input =  -90, output = {  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
  { input =  -20, output = {  1.00,    10,  0.37,  1.00,  3.00,  1.00,  1.00,  3.60,500.00,  0.04 } },
  }, hsvRows = { 2 }}
assert(lutJit:calculate(-95)[1] == 1)
```
Obsolete. Use `ac.Lut` instead, with faster C++ implementation.

- `ac.LutJit:new(o, data, hsvRows)`

  Creates new ac.LuaJit instance. Deprecated, use `ac.Lut` instead.

  Parameters:

    1. `data`: `any`

    2. `hsvRows`: `integer[]`  1-based indices of columns (not rows) storing HSV values in them.

  Returns:

    - `table`

- `ac.LutJit:calculate(input)`

  Computes a new value. Deprecated, use `ac.Lut` instead.

  Parameters:

    1. `input`: `number`

  Returns:

    - `number`

- `ac.LutJit:calculateTo(output, input)`

  Computes a new value to a preexisting HSV value. Deprecated, use `ac.Lut` instead.

  Parameters:

    1. `output`: `number[]`

    2. `input`: `number`

  Returns:

    - `number`
## Function ac.LutJit:new(o, data, hsvRows)
Creates new ac.LuaJit instance. Deprecated, use `ac.Lut` instead.

  Parameters:

  1. `data`: `any`

  2. `hsvRows`: `integer[]`  1-based indices of columns (not rows) storing HSV values in them.

  Returns:

  - `table`
## Function ac.LutJit:calculate(input)
Computes a new value. Deprecated, use `ac.Lut` instead.

  Parameters:

  1. `input`: `number`

  Returns:

  - `number`
## Function ac.LutJit:calculateTo(output, input)
Computes a new value to a preexisting HSV value. Deprecated, use `ac.Lut` instead.

  Parameters:

  1. `output`: `number[]`

  2. `input`: `number`

  Returns:

  - `number`

# Module common/ac_extras_onlineevent.lua

## Function ac.OnlineEvent(layout, callback, namespace)
Creates a new type of online event to exchange between scripts running on different clients in an online
race. Example:
```lua
local chatMessageEvent = ac.OnlineEvent({
  -- message structure layout:
  message = ac.StructItem.string(50),
  mood = ac.StructItem.float(),
}, function (sender, data)
  -- got a message from other client (or ourselves; in such case `sender.index` would be 0):
  ac.debug('Got message: from', sender and sender.index or -1)
  ac.debug('Got message: text', data.message)
  ac.debug('Got message: mood', data.mood)
end)

-- sending a new message:
chatMessageEvent{ message = 'hello world', mood = 5 }
```

Note: to exchange messages between two scripts, both of them chould use `ac.OnlineEvent()` and pass exactly the same layouts. Also, consider using more
specific names to avoid possible unwanted collisions. For example, instead of using `value = ac.StructItem.int()` which might be
used somewhere else, use `mySpecificValue = ac.StructItem.int()`. Or, simply add `ac.StructItem.key('myUniqueKey')`.

For safety reasons, car scripts can only exchange messages with other car scripts, and track scripts can only exchange messages with other track scripts.

Each message should be smaller than 175 bytes. At least 200 ms should pass between sending messages. Don’t use this system to exchange data too often: at
current stage, it uses chat messages to transfer data, so it’s far from optimal.

  Parameters:

  1. `layout`: `T` A table containing fields of structure and their types. Use `ac.StructItem` methods to select types. Alternatively, you can pass a string for the body of the structure here, but be careful with it.

  2. `callback`: `fun(sender: ac.StateCar|nil, message: T)` Callback that will be called when a new message of this type is received. Note: it would be called even if message was sent from this script. Use `sender` to check message origin: if it’s `nil`, message has come from the server, if its `.index` is 0, message has come from this client (and possibly this script).

  3. `namespace`: `nil|ac.SharedNamespace` Optional namespace stopping scripts of certain types to access data of scripts with different types. For more details check `ac.SharedNamespace` documentation.

  Returns:

  - `fun`

# Module common/ac_extras_connectmmf.lua

## Function ac.readMemoryMappedFile(filename, layout)
Opens shared memory file for reading.

  Parameters:

  1. `filename`: `string` Shared memory file filename (without “Local\” bit).

  2. `layout`: `T` String for the body of the structure.

  Returns:

  - `T`
## Function ac.writeMemoryMappedFile(filename, layout)
Opens shared memory file for writing.

  Parameters:

  1. `filename`: `string` Shared memory file filename (without “Local\” bit).

  2. `layout`: `T` String for the body of the structure.

  Returns:

  - `T`

# Module common/ac_general_utils.lua

## Function ac.evaluateLapTime()
Estimates lap time and sector times for main car using AC function originally used by Time Attack mode. Could be
helpful in creating custom time attack modes. Uses “ideal_line.ai” from “track folder/data”, so might not work
well with mods. If that file is missing, returns nil.

# Module common/ac_social.lua

## Function ac.DriverTags(driverName)
Faster way to deal with driver tags. Any request unsupported fields will return `false` for further extendability.
Scripts with access to I/O can also alter fields.

  Parameters:

  1. `driverName`: `string`

  Returns:

  - `ac.DriverTags`
## Class ac.DriverTags
Faster way to deal with driver tags. Any request unsupported fields will return `false` for further extendability.
Scripts with access to I/O can also alter fields.
## Function ac.isTaggedAsFriend(driverName)
Checks if a user is tagged as a friend. Uses CSP and CM databases. Deprecated, use `ac.DriverTags` instead.

  Parameters:

  1. `driverName`: `string` Driver name.

  Returns:

  - `boolean`
## Function ac.tagAsFriend(driverName, isFriend)
Tags user as a friend (or removes the tag if `false` is passed). Deprecated, use `ac.DriverTags` instead.

  Parameters:

  1. `driverName`: `string` Driver name.

  2. `isFriend`: `boolean?` Default value: `true`.

# Module common/ac_music.lua

## Class ac.MusicData
Information about currently playing track. Use function `ac.currentlyPlaying()` to get
a reference to it.

To draw album cover, pass `ac.MusicData` as an argument to something like `ui.image()`.
## Function ac.currentlyPlaying()
Syncs information about currently playing music and returns a table with details. Takes data from
Windows 10 Media API, or from other sources configured in Music module of CSP.

  Returns:

  - `ac.MusicData`

# Module common/ac_storage.lua

## Class ac.StoredValue

- `ac.StoredValue:get()`

  Returns:

    - `string|number|boolean|vec2|vec3|vec4|rgb|rgbm`

- `ac.StoredValue:set(value)`

  Parameters:

    1. `value`: `string|number|boolean|vec2|vec3|vec4|rgb|rgbm`
## Function ac.storage(layout, keyPrefix)
Storage function. Easiest way to use is to pass it a table with default values — it would give you a table back
which would load values on reads and save values on writes. Values have to be either strings, numbers, booleans,
vectors or colors. Example:
```lua
local storedValues = ac.storage{
  someKey = 15,
  someStringValue = 20
}
storedValues.someKey = 20
```
Alternatively, you can use it as a function which would take a key and a default value and return you an
`ac.StoredValue` wrapper with methods `:get()` and `:set(newValue)`:
```lua
local stored = ac.storage('someKey', 15)
stored:get()
stored:set(20)
```
Or, just access it directly in `localStorage` style of JavaScript. Similar to JavaScript, this way you can only store
strings:
```lua
ac.storage.key = 'value'
ac.debug('loaded', ac.storage.key)
```
Data will be saved in “Documents\Assetto Corsa\cfg\extension\state\lua”, in corresponding subfolder. Actual writing
will happen a few seconds after new value was pushed, and only if value was changed, so feel free to use this function
to write things often.

  Parameters:

  1. `layout`: `T`

  2. `keyPrefix`: `string|nil` Optional parameter for adding a prefix to keys.

  Returns:

  - `T`
## Function ac.storageHasKey(storage, key)
Checks if storage table created by `ac.storage(table)` has a certain key or not.

  Parameters:

  1. `storage`: `any`

  2. `key`: `string`

  Returns:

  - `boolean`
## Function ac.storageChanged()
Returns `true` if any storage value has changed since the previous call.

  Returns:

  - `boolean`

# Module common/ac_configs.lua

## Class ac.ConfigProvider

- `ac.ConfigProvider.bool(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `boolean|nil`

  Returns:

    - `boolean`

- `ac.ConfigProvider.number(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `number`

  Returns:

    - `number`

- `ac.ConfigProvider.string(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `string|nil`

  Returns:

    - `string`

- `ac.ConfigProvider.rgb(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `rgb|nil`

  Returns:

    - `rgb`

- `ac.ConfigProvider.rgbm(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `rgbm|nil`

  Returns:

    - `rgbm`

- `ac.ConfigProvider.vec2(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `vec2|nil`

  Returns:

    - `vec2`

- `ac.ConfigProvider.vec3(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `vec3|nil`

  Returns:

    - `vec3`

- `ac.ConfigProvider.vec4(section, key, defaultValue)`

  Parameters:

    1. `section`: `string`

    2. `key`: `string`

    3. `defaultValue`: `vec4|nil`

  Returns:

    - `vec4`
## Function ac.getTrackConfig(section, key, defaultValue)
Reads a value from the config of currently loaded track. To use it, you need to specify `defaultValue` value, it would be used to determine
the type of the value you need (and would be returned if value in config is missing).

Alternatively, if called without arguments, returns ac.ConfigProvider which then can be used to access
values in a typed manner. For it, `defaultValue` is optional.

  Parameters:

  1. `section`: `string` Section name in config (the one in square brackets).

  2. `key`: `string` Config key (value before “=” sign).

  3. `defaultValue`: `T` Value that’s returned as a result if value is missing. Also determines the type needed.

  Returns:

  - `T`
## Function ac.getCarConfig(carIndex, section, key, defaultValue)
Reads a value from the config of a car. To use it, you need to specify `defaultValue` value, it would be used to determine
the type of the value you need (and would be returned if value in config is missing).

Alternatively, if called with car index only, returns ac.ConfigProvider which then can be used to access
values in a typed manner. For it, `defaultValue` is optional.

  Parameters:

  1. `carIndex`: `integer` 0-based car index.

  2. `section`: `string` Section name in config (the one in square brackets).

  3. `key`: `string` Config key (value before “=” sign).

  4. `defaultValue`: `T` Value that’s returned as a result if value is missing. Also determines the type needed.

  Returns:

  - `T`

# Module common/ac_reftypes.lua

## Function refbool(value)
Stores a boolean value and can be used as a reference to it.

  Parameters:

  1. `value`: `boolean` Stored value.

  Returns:

  - `refbool`
## Class refbool
Stores a boolean value and can be used as a reference to it.

- `refbool.isrefbool(x)`

  Returns:

    - `boolean`

- `refbool:set(newValue)`

  For easier use with UI controls.

  Parameters:

    1. `newValue`: `boolean|`true`|`false``

  Returns:

    - `refbool`
## Function refnumber(value)
Stores a numerical value and can be used as a reference to it.

  Parameters:

  1. `value`: `number` Stored value.

  Returns:

  - `refnumber`
## Class refnumber
Stores a numerical value and can be used as a reference to it.

- `refnumber.isrefnumber(x)`

  Returns:

    - `boolean`

- `refnumber:set(newValue)`

  For easier use with UI controls.

  Parameters:

    1. `newValue`: `number`

  Returns:

    - `refnumber`

# Module common/ac_dualsense.lua

## Function ac.getDualSenseControllers()
Return table with gamepad indices for keys and 0-based indices of associated cars for values.

  Returns:

  - `table`

# Module common/ac_dualshock.lua

## Function ac.getDualShockControllers()
Return table with gamepad indices for keys and 0-based indices of associated cars for values.

  Returns:

  - `table`

# Module common/ac_web.lua

## Class WebResponse
## Function web.get(url, headers, callback)
Sends a GET HTTP request. Note: you can only have two requests running at once, mostly to make sure
a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
to one of my API tokens for some time, accidentally sending a request each frame).

  Parameters:

  1. `url`: `string` URL.

  2. `headers`: `table<string, string|number|boolean>?` Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).

  3. `callback`: `fun(err: string, response: WebResponse)`
## Function web.post(url, headers, data, callback)
Sends a POST HTTP request. Note: you can only have two requests running at once, mostly to make sure
a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
to one of my API tokens for some time, accidentally sending a request each frame).

  Parameters:

  1. `url`: `string` URL.

  2. `headers`: `table<string, string|number|boolean>?` Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).

  3. `data`: `WebPayload` Optional data.

  4. `callback`: `fun(err: string, response: WebResponse)`
## Function web.request(method, url, headers, data, callback)
Sends a custom HTTP request. Note: you can only have two requests running at once, mostly to make sure
a faulty script wouldn’t spam a remote server or overload internet connection (that’s how I lost access
to one of my API tokens for some time, accidentally sending a request each frame).

  Parameters:

  1. `method`: `"'GET'"|"'POST'"|"'PUT'"|"'HEAD'"|"'DELETE'"|"'PATCH'"|"'OPTIONS'"` HTTP method.

  2. `url`: `string` URL.

  3. `headers`: `table<string, string|number|boolean>?` Optional headers. Use special `[':headers-only'] = true` header if you only need to load headers (for servers without proper support of HEAD method).

  4. `data`: `WebPayload` Optional data.

  5. `callback`: `fun(err: string, response: WebResponse)`

# Module common/stringify.lua

## Function stringify(obj, compact, depthLimit)
Serialize Lua value (table, number, string, etc.) in a Lua table format (similar to how `JSON.stringify` in JavaScript
generates a thing with JavaScript syntax). Format seems to be called Luaon. Most of Lua entities are supported, including array-like tables, table
tables and mixed ones. CSP API things, such as vectors or colors, are also supported. For things like threads,
functions or unknown cdata types instead a placeholder object will be created.

Circular references also result in creating similar objects, for example: `t = {1, 2, 3, t}` would result in
`{ 1, 2, 3, { type = 'circular reference' } }`.

If any table in given data would have a `__stringify()` function, it would be called as a method (so first argument
would be the table with `__stringify` itself). If that function would return a string, that string will be used
instead of regular table serialization. The idea is for classes to define a method like this and output a line of code
which could be used to create a new instance like this on deserialization. Note: for such like to use a custom function
like a class constructor, you would either need to register that function with a certain name or provide a table referring
to it on deserialization. That’s because although deserialization uses `load()` function to parse and run data as Lua code,
it wouldn’t allow code to access existing functions by default.

  Parameters:

  1. `obj`: `table|number|string|boolean|nil` Object to serialize.

  2. `compact`: `boolean?` If true, resulting string would not have spaces and line breaks, slightly faster and a lot more compact.

  3. `depthLimit`: `integer?` Limits how deep serialization would go. Default value: 20.

  Returns:

  - `string` String with input data presented in Lua syntax.
## Function stringify.parse(serialized, namespace)
Parse a string with Lua table syntax into a Lua object (table, number, string, vector, etc.), can support custom objects as well.
Only functions from `namespace` can be used (as well as vectors and functions registered earlier with `stringify.register()`),
so if you’re using custom classes, make sure to either register them earlier or pass them in `namespace` table. Alternatively,
you can just pass `_G` as `namespace`, but it might be pretty unsecure, so maybe don’t do it.

Would raise an error if failed to parse or if any of initializers would raise an error.

  Parameters:

  1. `serialized`: `string` Serialized data.

  2. `namespace`: `table<string, function>|nil` Namespace table. Serialized data would be evaluated as Lua code and would have access to it.

  Returns:

  - `table|number|string|boolean|nil`
## Function stringify.tryParse(serialized, namespace, fallback)
Parse a string with Lua table syntax into a Lua object (table, number, string, vector, etc.), can support custom objects as well.
Only functions from `namespace` can be used (as well as vectors and functions registered earlier with `stringify.register()`),
so if you’re using custom classes, make sure to either register them earlier or pass them in `namespace` table. Alternatively,
you can just pass `_G` as `namespace`, but it might be pretty unsecure, so maybe don’t do it.

Returns fallback value if failed to parse, or if `serialized` is empty or not set, or if any of initializers would raise an error.

  Parameters:

  1. `serialized`: `string?` Serialized data.

  2. `namespace`: `table<string, function>|nil` Namespace table. Serialized data would be evaluated as Lua code and would have access to it.

  3. `fallback`: `T|nil` Value to return if parsing failed.

  Returns:

  - `T`
## Function stringify.register(name, fn)
Registers a new initializer function with a given name.

  Parameters:

  1. `name`: `string` Name of an initializer (how serialized data would refer to it).

  2. `fn`: `function` Initializer function (returning value for serialized data to use).
## Function stringify.substep(out, ptr, obj, lineBreak, depthLimit)
Serialization substep. Works similar to `stringify()` itself, but instead of returning string simply adds new terms to
`out` table. Use it in custom `__stringify` methods for serializing child items if you need the best performance.

  Parameters:

  1. `out`: `string[]` Output table with words to concatenate later (without any joining string).

  2. `ptr`: `integer` Position within `out` table to write next word into. At the very start, when table is empty, it would be 1.

  3. `obj`: `any` Item to serialize.

  4. `lineBreak`: `string|nil` Line break with some spaces for aligning child items, or `nil` if compact stringify mode is used. One tab is two spaces.

  5. `depthLimit`: `integer` Limits how many steps down serialization can go. If 0 or below, no tables would be serialized.

  Returns:

  - `integer` Updated `ptr` value (if one item was added to `out`, should increase by 1).
## Function stringify.binary(obj)
Different serializer, produces binary data instead of human-readable. Faster and with even more compact output, but not human-readable.

  Parameters:

  1. `obj`: `table|number|string|boolean|nil` Object to serialize.

  Returns:

  - `string` String with input data presented in binary format, so it won’t be readable and will contain zero bytes.
## Function stringify.binary.parse(serialized)
Parses binary data prepared with `stringify.binary()`.

  Parameters:

  1. `serialized`: `string` Serialized data.

  Returns:

  - `table|number|string|boolean|nil`
## Function stringify.binary.tryParse(serialized, fallback)
Tries to parse binary data prepared with `stringify.binary()`.

Returns fallback value if failed to parse, or if `serialized` is empty or not set, or if any of initializers would raise an error.

  Parameters:

  1. `serialized`: `string?` Serialized data.

  2. `fallback`: `T|nil` Value to return if parsing failed.

  Returns:

  - `T`
## Class ClassStringifiable
A small helper to add as a parent class for EmmyLua to work better.

- `ClassStringifiable:__stringify(out, ptr, obj, lineBreak, depthLimit)`

  Serialize instance of class. Can either return a `string`, or construct it into `out` table and return a new position in it. String itself should be a like of
Lua code which would reconstruct the object on deserialization. Don’t forget to either register referred function with `stringify.register()` or provide
a reference to it in `namespace` table with `stringify.parse()`.

Note: to serialize sub-objects, such as constructor arguments, you can use `stringify()` or `stringify.substep()` if you’re using an approach with
manually constructing `out` table. Alternatively for basic types you can use `string.format()`: “%q” would give you a string in Lua format, so you can use it
like so:
```lua
function MyClass:__serialize()
  return string.format('MyClass(%q, %s)', self.stringName, self.numericalCounter)
end
```

  Parameters:

    1. `out`: `string[]` Output table with words to concatenate later (without any joining string).

    2. `ptr`: `integer` Position within `out` table to write next word into. At the very start, when table is empty, it would be 1.

    3. `obj`: `any` Item to serialize.

    4. `lineBreak`: `string|nil` Line break with some spaces for aligning child items, or `nil` if compact stringify mode is used. One tab is two spaces.

    5. `depthLimit`: `integer` Limits how many steps down serialization can go. If 0 or below, no tables would be serialized.

  Returns:

    - `integer` Updated `ptr` value (if one item was added to `out`, should increase by 1).

# Module common/json.lua

## Function JSON.stringify(data)
Serializes a Lua entity (like a table) into a compact JSON.

  Parameters:

  1. `data`: `table|number|string|boolean|nil`

  Returns:

  - `string`
## Function JSON.parse(data)
Parses a compact JSON into a Lua entity. Note: if JSON is damaged, parser won’t throw an error, but
results might be somewhat unpredictable. It’s an intended behaviour: in 99% of cases JSON parser
used to exchange data with, for example, API endpoints, will receive correct data, but some of those
AC JSON files are pretty screwed and often include things like missing commas, comments, etc.

  Parameters:

  1. `data`: `string?`

  Returns:

  - `any`

# Module common/ac_primitive_vec2.d.lua

## Function vec2.new(x, y)
Creates new vector. It’s usually faster to create a new item with `vec2(x, y)` directly, but the way LuaJIT works,
that call only works with two numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Returns:

  - `vec2`
## Function vec2.isvec2(p)
Checks if value is vec2 or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function vec2.tmp()
Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `vec2`
## Function vec2.intersect(p1, p2, p3, p4)
Intersects two line segments, one going from `p1` to `p2` and another going from `p3` to `p4`. Returns intersection point or `nil` if there is no intersection.

  Returns:

  - `vec2`
## Function vec2(x, y)
Two-dimensional vector. All operators are overloaded. Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec2()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec2()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  Returns:

  - `vec2`
## Class vec2
Two-dimensional vector. All operators are overloaded. Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec2()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec2()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

- `vec2.new(x, y)`

  Creates new vector. It’s usually faster to create a new item with `vec2(x, y)` directly, but the way LuaJIT works,
that call only works with two numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Returns:

    - `vec2`

- `vec2.isvec2(p)`

  Checks if value is vec2 or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `vec2.tmp()`

  Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `vec2`

- `vec2.intersect(p1, p2, p3, p4)`

  Intersects two line segments, one going from `p1` to `p2` and another going from `p3` to `p4`. Returns intersection point or `nil` if there is no intersection.

  Returns:

    - `vec2`

- `vec2:clone()`

  Makes a copy of a vector.

  Returns:

    - `vec2`

- `vec2:unpack()`

  Unpacks vec2 into rgb and number.

  Returns:

    - `rgb`

- `vec2:table()`

  Turns vec2 into a table with two values.

  Returns:

    - `number`

- `vec2:type()`

  Returns reference to vec2 class.
function vec2:type() end

- `vec2:set(x, y)`

  Parameters:

    1. `x`: `vec2|number`

    2. `y`: `number?`

  Returns:

    - `vec2` Returns itself.

- `vec2:setScaled(vec, scale)`

  Parameters:

    1. `vec`: `vec2`

    2. `scale`: `number`

  Returns:

    - `vec2` Returns itself.

- `vec2:setLerp(value1, value2, mix)`

  Parameters:

    1. `value1`: `vec2`

    2. `value2`: `vec2`

    3. `mix`: `number`

  Returns:

    - `vec2` Returns itself.

- `vec2:copyTo(out)`

  Copies its values to a different vector.

  Parameters:

    1. `out`: `vec2`

  Returns:

    - `vec2` Returns itself.

- `vec2:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `vec2|number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:addScaled(valueToAdd, scale, out)`

  Parameters:

    1. `valueToAdd`: `vec2`

    2. `scale`: `number`

    3. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `vec2|number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `vec2`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:div(valueToDivideBy, out)`

  Parameters:

    1. `valueToDivideBy`: `vec2`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:pow(exponent, out)`

  Parameters:

    1. `exponent`: `vec2|number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:min(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec2|number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:max(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec2|number`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:saturate(out)`

  Parameters:

    1. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:clamp(min, max, out)`

  Parameters:

    1. `min`: `vec2`

    2. `max`: `vec2`

    3. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:length()`

  Returns:

    - `number`

- `vec2:lengthSquared()`

  Returns:

    - `number`

- `vec2:distance(otherVector)`

  Parameters:

    1. `otherVector`: `vec2`

  Returns:

    - `number`

- `vec2:distanceSquared(otherVector)`

  Parameters:

    1. `otherVector`: `vec2`

  Returns:

    - `number`

- `vec2:closerToThan(otherVector, distanceThreshold)`

  Parameters:

    1. `otherVector`: `vec2`

    2. `distanceThreshold`: `number`

  Returns:

    - `boolean`

- `vec2:angle(otherVector)`

  Parameters:

    1. `otherVector`: `vec2`

  Returns:

    - `number` Radians.

- `vec2:dot(otherVector)`

  Parameters:

    1. `otherVector`: `vec2`

  Returns:

    - `number`

- `vec2:normalize(out)`

  Normalizes itself (unless different `out` is provided).

  Parameters:

    1. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:lerp(otherVector, mix, out)`

  Rewrites own values with values of lerp of itself and other vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec2`

    2. `mix`: `number`

    3. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

- `vec2:project(otherVector, out)`

  Rewrites own values with values of projection of itself onto another vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec2`

    2. `out`: `vec2|nil` Optional destination argument.

  Returns:

    - `vec2` Returns itself or out value.

# Module common/ac_primitive_vec3.d.lua

## Function vec3.new(x, y, z)
Creates new vector. It’s usually faster to create a new item with `vec3(x, y, z)` directly, but the way LuaJIT works,
that call only works with three numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  Returns:

  - `vec3`
## Function vec3.isvec3(p)
Checks if value is vec3 or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function vec3.tmp()
Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `vec3`
## Function vec3(x, y, z)
Three-dimensional vector. All operators are overloaded.
Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec3()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec3()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  Returns:

  - `vec3`
## Class vec3
Three-dimensional vector. All operators are overloaded.
Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec3()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec3()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

- `vec3.new(x, y, z)`

  Creates new vector. It’s usually faster to create a new item with `vec3(x, y, z)` directly, but the way LuaJIT works,
that call only works with three numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

    1. `x`: `number?`

    2. `y`: `number?`

    3. `z`: `number?`

  Returns:

    - `vec3`

- `vec3.isvec3(p)`

  Checks if value is vec3 or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `vec3.tmp()`

  Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `vec3`

- `vec3:clone()`

  Makes a copy of a vector.

  Returns:

    - `vec3`

- `vec3:unpack()`

  Unpacks vec3 into rgb and number.

  Returns:

    - `rgb`

- `vec3:table()`

  Turns vec3 into a table with three values.

  Returns:

    - `number`

- `vec3:type()`

  Returns reference to vec3 class.
function vec3:type() end

- `vec3:set(x, y, z)`

  Parameters:

    1. `x`: `vec3|number`

    2. `y`: `number?`

    3. `z`: `number?`

  Returns:

    - `vec3` Returns itself.

- `vec3:setScaled(vec, scale)`

  Parameters:

    1. `vec`: `vec3`

    2. `scale`: `number`

  Returns:

    - `vec3` Returns itself.

- `vec3:setLerp(value1, value2, mix)`

  Parameters:

    1. `value1`: `vec3`

    2. `value2`: `vec3`

    3. `mix`: `number`

  Returns:

    - `vec3` Returns itself.

- `vec3:setCrossNormalized(value1, value2)`

  Sets itself to a normalized result of cross product of value1 and value2.

  Parameters:

    1. `value1`: `vec3`

    2. `value2`: `vec3`

  Returns:

    - `vec3` Returns itself.

- `vec3:copyTo(out)`

  Copies its values to a different vector.

  Parameters:

    1. `out`: `vec3`

  Returns:

    - `vec3` Returns itself.

- `vec3:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `vec3|number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:addScaled(valueToAdd, scale, out)`

  Parameters:

    1. `valueToAdd`: `vec3`

    2. `scale`: `number`

    3. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `vec3|number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `vec3`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:div(valueToDivideBy, out)`

  Parameters:

    1. `valueToDivideBy`: `vec3`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:pow(exponent, out)`

  Parameters:

    1. `exponent`: `vec3|number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:min(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec3|number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:max(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec3|number`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:saturate(out)`

  Parameters:

    1. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:clamp(min, max, out)`

  Parameters:

    1. `min`: `vec3`

    2. `max`: `vec3`

    3. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:length()`

  Returns:

    - `number`

- `vec3:lengthSquared()`

  Returns:

    - `number`

- `vec3:distance(otherVector)`

  Parameters:

    1. `otherVector`: `vec3`

  Returns:

    - `number`

- `vec3:distanceSquared(otherVector)`

  Parameters:

    1. `otherVector`: `vec3`

  Returns:

    - `number`

- `vec3:closerToThan(otherVector, distanceThreshold)`

  Parameters:

    1. `otherVector`: `vec3`

    2. `distanceThreshold`: `number`

  Returns:

    - `boolean`

- `vec3:angle(otherVector)`

  Parameters:

    1. `otherVector`: `vec3`

  Returns:

    - `number` Radians.

- `vec3:dot(otherVector)`

  Parameters:

    1. `otherVector`: `vec3`

  Returns:

    - `number`

- `vec3:normalize(out)`

  Normalizes itself (unless different `out` is provided).

  Parameters:

    1. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:cross(otherVector, out)`

  Rewrites own values with values of cross product of itself and other vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec3`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:lerp(otherVector, mix, out)`

  Rewrites own values with values of lerp of itself and other vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec3`

    2. `mix`: `number`

    3. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:project(otherVector, out)`

  Rewrites own values with values of projection of itself onto another vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec3`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:rotate(quaternion, out)`

  Rewrites own values with values of itself rotated with quaternion (unless different `out` is provided).

  Parameters:

    1. `quaternion`: `quat`

    2. `out`: `vec3|nil` Optional destination argument.

  Returns:

    - `vec3` Returns itself or out value.

- `vec3:distanceToLine(a, b)`

  Returns distance from point to a line. For performance reasons doesn’t do any checks, so be careful with incoming arguments.

  Returns:

    - `number`

- `vec3:distanceToLineSquared(a, b)`

  Returns squared distance from point to a line. For performance reasons doesn’t do any checks, so be careful with incoming arguments.

  Returns:

    - `number`

# Module common/ac_primitive_vec4.d.lua

## Function vec4.new(x, y, z, w)
Creates new vector. It’s usually faster to create a new item with `vec4(x, y, z, w)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  4. `w`: `number?`

  Returns:

  - `vec4`
## Function vec4.isvec4(p)
Checks if value is vec4 or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function vec4.tmp()
Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `vec4`
## Function vec4(x, y, z, w)
Four-dimensional vector. All operators are also overloaded.
Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec4()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec4()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  4. `w`: `number?`

  Returns:

  - `vec4`
## Class vec4
Four-dimensional vector. All operators are also overloaded.
Note: creating a lot of new vectors can create extra work for garbage collector reducing overall effectiveness.
Where possible, instead of using mathematical operators consider using methods altering state of already existing vectors. So, instead of:
```lua
someVec = vec4()
…
someVec = math.normalize(vec1 + vec2) * 10
```
Consider rewriting it like:
```lua
someVec = vec4()
…
someVec:set(vec1):add(vec2):normalize():scale(10)
```

- `vec4.new(x, y, z, w)`

  Creates new vector. It’s usually faster to create a new item with `vec4(x, y, z, w)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

    1. `x`: `number?`

    2. `y`: `number?`

    3. `z`: `number?`

    4. `w`: `number?`

  Returns:

    - `vec4`

- `vec4.isvec4(p)`

  Checks if value is vec4 or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `vec4.tmp()`

  Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `vec4`

- `vec4:clone()`

  Makes a copy of a vector.

  Returns:

    - `vec4`

- `vec4:unpack()`

  Unpacks vec4 into rgb and number.

  Returns:

    - `rgb`

- `vec4:table()`

  Turns vec4 into a table with four values.

  Returns:

    - `number`

- `vec4:type()`

  Returns reference to vec4 class.
function vec4:type() end

- `vec4:set(x, y, z, w)`

  Parameters:

    1. `x`: `vec4|number`

    2. `y`: `number?`

    3. `z`: `number?`

    4. `w`: `number?`

  Returns:

    - `vec4` Returns itself.

- `vec4:setScaled(vec, scale)`

  Parameters:

    1. `vec`: `vec4`

    2. `scale`: `number`

  Returns:

    - `vec4` Returns itself.

- `vec4:setLerp(value1, value2, mix)`

  Parameters:

    1. `value1`: `vec4`

    2. `value2`: `vec4`

    3. `mix`: `number`

  Returns:

    - `vec4` Returns itself.

- `vec4:setCrossNormalized(value1, value2)`

  Sets itself to a normalized result of cross product of value1 and value2.

  Parameters:

    1. `value1`: `vec4`

    2. `value2`: `vec4`

  Returns:

    - `vec4` Returns itself.

- `vec4:copyTo(out)`

  Copies its values to a different vector.

  Parameters:

    1. `out`: `vec4`

  Returns:

    - `vec4` Returns itself.

- `vec4:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `vec4|number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:addScaled(valueToAdd, scale, out)`

  Parameters:

    1. `valueToAdd`: `vec4`

    2. `scale`: `number`

    3. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `vec4|number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `vec4`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:div(valueToDivideBy, out)`

  Parameters:

    1. `valueToDivideBy`: `vec4`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:pow(exponent, out)`

  Parameters:

    1. `exponent`: `vec4|number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:min(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec4|number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:max(otherValue, out)`

  Parameters:

    1. `otherValue`: `vec4|number`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:saturate(out)`

  Parameters:

    1. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:clamp(min, max, out)`

  Parameters:

    1. `min`: `vec4`

    2. `max`: `vec4`

    3. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:length()`

  Returns:

    - `number`

- `vec4:lengthSquared()`

  Returns:

    - `number`

- `vec4:distance(otherVector)`

  Parameters:

    1. `otherVector`: `vec4`

  Returns:

    - `number`

- `vec4:distanceSquared(otherVector)`

  Parameters:

    1. `otherVector`: `vec4`

  Returns:

    - `number`

- `vec4:closerToThan(otherVector, distanceThreshold)`

  Parameters:

    1. `otherVector`: `vec4`

    2. `distanceThreshold`: `number`

  Returns:

    - `boolean`

- `vec4:angle(otherVector)`

  Parameters:

    1. `otherVector`: `vec4`

  Returns:

    - `number` Radians.

- `vec4:dot(otherVector)`

  Parameters:

    1. `otherVector`: `vec4`

  Returns:

    - `number`

- `vec4:normalize(out)`

  Normalizes itself (unless different `out` is provided).

  Parameters:

    1. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:lerp(otherVector, mix, out)`

  Rewrites own values with values of lerp of itself and other vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec4`

    2. `mix`: `number`

    3. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

- `vec4:project(otherVector, out)`

  Rewrites own values with values of projection of itself onto another vector (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `vec4`

    2. `out`: `vec4|nil` Optional destination argument.

  Returns:

    - `vec4` Returns itself or out value.

# Module common/ac_primitive_rgb.d.lua

## Function rgb.new(r, g, b, m)
Creates new instance. It’s usually faster to create a new item with `rgb(r, g, b, mult)` directly, but the way LuaJIT works,
that call only works with three numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

  1. `r`: `number?`

  2. `g`: `number?`

  3. `b`: `number?`

  Returns:

  - `rgb`
## Function rgb.isrgb(p)
Checks if value is rgb or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function rgb.tmp()
Temporary color. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `rgb`
## Function rgb.from0255(r, g, b, a)
Creates color from 0…255 values

  Parameters:

  1. `r`: `number` From 0 to 255

  2. `g`: `number` From 0 to 255

  3. `b`: `number` From 0 to 255

  Returns:

  - `rgb`
## Function rgb(r, g, b)
Three-channel color. All operators are overloaded. White is usually `rgb=1,1,1`.

  Parameters:

  1. `r`: `number?`

  2. `g`: `number?`

  3. `b`: `number?`

  Returns:

  - `rgb`
## Class rgb
Three-channel color. All operators are overloaded. White is usually `rgb=1,1,1`.

- `rgb.new(r, g, b, m)`

  Creates new instance. It’s usually faster to create a new item with `rgb(r, g, b, mult)` directly, but the way LuaJIT works,
that call only works with three numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

    1. `r`: `number?`

    2. `g`: `number?`

    3. `b`: `number?`

  Returns:

    - `rgb`

- `rgb.isrgb(p)`

  Checks if value is rgb or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `rgb.tmp()`

  Temporary color. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `rgb`

- `rgb.from0255(r, g, b, a)`

  Creates color from 0…255 values

  Parameters:

    1. `r`: `number` From 0 to 255

    2. `g`: `number` From 0 to 255

    3. `b`: `number` From 0 to 255

  Returns:

    - `rgb`

- `rgb:clone()`

  Makes a copy of a vector.

  Returns:

    - `rgb`

- `rgb:unpack()`

  Unpacks rgb into three numbers.

  Returns:

    - `rgb`

- `rgb:table()`

  Turns rgb into a table with three numbers.

  Returns:

    - `number`

- `rgb:type()`

  Returns reference to rgb class.
function rgb:type() end

- `rgb:set(r, g, b)`

  Parameters:

    1. `r`: `rgb|number`

    2. `g`: `number?`

    3. `b`: `number?`

  Returns:

    - `rgb` Returns itself.

- `rgb:setScaled(x, mult)`

  Parameters:

    1. `x`: `rgb`

    2. `mult`: `number`

  Returns:

    - `rgb` Returns itself.

- `rgb:setLerp(value1, value2, mix)`

  Parameters:

    1. `value1`: `rgb`

    2. `value2`: `rgb`

    3. `mix`: `number`

  Returns:

    - `rgb` Returns itself.

- `rgb:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `rgb|number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:addScaled(valueToAdd, scale, out)`

  Parameters:

    1. `valueToAdd`: `rgb`

    2. `scale`: `number`

    3. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `rgb|number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `rgb`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:div(valueToDivideBy, out)`

  Parameters:

    1. `valueToDivideBy`: `rgb`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:pow(exponent, out)`

  Parameters:

    1. `exponent`: `rgb|number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:min(otherValue, out)`

  Parameters:

    1. `otherValue`: `rgb|number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:max(otherValue, out)`

  Parameters:

    1. `otherValue`: `rgb|number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:saturate(out)`

  Parameters:

    1. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:clamp(min, max, out)`

  Parameters:

    1. `min`: `rgb`

    2. `max`: `rgb`

    3. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:adjustSaturation(saturation, out)`

  Adjusts saturation using a very simple formula.

  Parameters:

    1. `saturation`: `number`

    2. `out`: `rgb|nil` Optional destination argument.

  Returns:

    - `rgb` Returns itself or out value.

- `rgb:normalize()`

  Makes sure brightest value does not exceed 1.

  Returns:

    - `rgb` Returns itself.

- `rgb:value()`

  Returns brightest value (aka V in HSV).

  Returns:

    - `number`

- `rgb:hue()`

  Returns hue.

  Returns:

    - `number`

- `rgb:saturation()`

  Returns saturation.

  Returns:

    - `number`

- `rgb:luminance()`

  Returns luminance value.

  Returns:

    - `number`

- `rgb:rgbm(mult)`

  Returns rgbm.

  Parameters:

    1. `mult`: `number?` Default value: 1.

  Returns:

    - `rgbm`

- `rgb:hsv()`

  Returns HSV color of rgb*mult.

  Returns:

    - `hsv`

- `rgb:vec3()`

  Returns rgb*mult turned to vec3.

  Returns:

    - `vec3`

# Module common/ac_primitive_hsv.d.lua

## Function hsv.new(h, s, v)
Creates new instance. It’s usually faster to create a new item with `hsv(h, s, v)`.

  Parameters:

  1. `h`: `number?`

  2. `s`: `number?`

  3. `v`: `number?`

  Returns:

  - `hsv`
## Function hsv.ishsv(p)
Checks if value is hsv or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function hsv.tmp()
Temporary HSV color. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `hsv`
## Function hsv(h, s, v)
HSV color (hue, saturation, value). Equality operator is overloaded.

  Parameters:

  1. `h`: `number?`

  2. `s`: `number?`

  3. `v`: `number?`

  Returns:

  - `hsv`
## Class hsv
HSV color (hue, saturation, value). Equality operator is overloaded.

- `hsv.new(h, s, v)`

  Creates new instance. It’s usually faster to create a new item with `hsv(h, s, v)`.

  Parameters:

    1. `h`: `number?`

    2. `s`: `number?`

    3. `v`: `number?`

  Returns:

    - `hsv`

- `hsv.ishsv(p)`

  Checks if value is hsv or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `hsv.tmp()`

  Temporary HSV color. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `hsv`

- `hsv:clone()`

  Makes a copy of a vector.

  Returns:

    - `hsv`

- `hsv:unpack()`

  Unpacks hsv into three numbers.

  Returns:

    - `rgb`

- `hsv:table()`

  Turns hsv into a table with three numbers.

  Returns:

    - `number`

- `hsv:type()`

  Returns reference to hsv class.
function hsv:type() end

- `hsv:set(h, s, v)`

  Parameters:

    1. `h`: `number`

    2. `s`: `number`

    3. `v`: `number`

  Returns:

    - `hsv` Returns itself.

- `hsv:rgb()`

  Returns RGB color.

  Returns:

    - `rgb`

# Module common/ac_primitive_rgbm.d.lua

## Function rgbm.new(r, g, b, m)
Creates new instance. It’s usually faster to create a new item with `rgbm(r, g, b, mult)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

  1. `r`: `number?`

  2. `g`: `number?`

  3. `b`: `number?`

  4. `m`: `number?` Default value: 1.

  Returns:

  - `rgbm`
## Function rgbm.isrgbm(p)
Checks if value is rgbm or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function rgbm.tmp()
Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `rgbm`
## Function rgbm.from0255(r, g, b, a)
Creates color from 0…255 values

  Parameters:

  1. `r`: `number` From 0 to 255.

  2. `g`: `number` From 0 to 255.

  3. `b`: `number` From 0 to 255.

  4. `a`: `number?` From 0 to 1. Default value: 1.

  Returns:

  - `rgbm`
## Function rgbm(r, g, b, mult)
Four-channel color. Fourth value, `mult`, can be used for alpha, for brightness, anything like that. All operators are also 
overloaded. White is usually `rgb=1,1,1`.

  Parameters:

  1. `r`: `number?`

  2. `g`: `number?`

  3. `b`: `number?`

  4. `mult`: `number?`

  Returns:

  - `rgbm`
## Class rgbm
Four-channel color. Fourth value, `mult`, can be used for alpha, for brightness, anything like that. All operators are also 
overloaded. White is usually `rgb=1,1,1`.

- `rgbm.new(r, g, b, m)`

  Creates new instance. It’s usually faster to create a new item with `rgbm(r, g, b, mult)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

    1. `r`: `number?`

    2. `g`: `number?`

    3. `b`: `number?`

    4. `m`: `number?` Default value: 1.

  Returns:

    - `rgbm`

- `rgbm.isrgbm(p)`

  Checks if value is rgbm or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `rgbm.tmp()`

  Temporary vector. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `rgbm`

- `rgbm.from0255(r, g, b, a)`

  Creates color from 0…255 values

  Parameters:

    1. `r`: `number` From 0 to 255.

    2. `g`: `number` From 0 to 255.

    3. `b`: `number` From 0 to 255.

    4. `a`: `number?` From 0 to 1. Default value: 1.

  Returns:

    - `rgbm`

- `rgbm:clone()`

  Makes a copy of a vector.

  Returns:

    - `rgbm`

- `rgbm:unpack()`

  Unpacks rgbm into rgb and number.

  Returns:

    - `rgb`

- `rgbm:table()`

  Turns rgbm into a table with four values.

  Returns:

    - `number`

- `rgbm:type()`

  Returns reference to rgbm class.
function rgbm:type() end

- `rgbm:set(rgb, mult)`

  Parameters:

    1. `rgb`: `rgbm|rgb`

    2. `mult`: `number?`

  Returns:

    - `rgbm` Returns itself.

- `rgbm:setLerp(value1, value2, mix)`

  Parameters:

    1. `value1`: `rgbm`

    2. `value2`: `rgbm`

    3. `mix`: `number`

  Returns:

    - `rgbm` Returns itself.

- `rgbm:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `rgbm|number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:addScaled(valueToAdd, scale, out)`

  Parameters:

    1. `valueToAdd`: `rgbm`

    2. `scale`: `number`

    3. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `rgbm|number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `rgbm`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:div(valueToDivideBy, out)`

  Parameters:

    1. `valueToDivideBy`: `rgbm`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:pow(exponent, out)`

  Parameters:

    1. `exponent`: `rgbm|number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:min(otherValue, out)`

  Parameters:

    1. `otherValue`: `rgbm|number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:max(otherValue, out)`

  Parameters:

    1. `otherValue`: `rgbm|number`

    2. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:saturate(out)`

  Parameters:

    1. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:clamp(min, max, out)`

  Parameters:

    1. `min`: `rgbm`

    2. `max`: `rgbm`

    3. `out`: `rgbm|nil` Optional destination argument.

  Returns:

    - `rgbm` Returns itself or out value.

- `rgbm:normalize()`

  Makes sure brightest value does not exceed 1.

  Returns:

    - `rgbm` Returns itself.

- `rgbm:value()`

  Returns brightest value.

  Returns:

    - `number`

- `rgbm:luminance()`

  Returns luminance value.

  Returns:

    - `number`

- `rgbm:color()`

  Returns color (rgb*mult).

  Returns:

    - `rgb`

- `rgbm:hsv()`

  Returns HSV color of rgb*mult.

  Returns:

    - `hsv`

- `rgbm:vec3()`

  Returns rgb*mult turned to vec3.

  Returns:

    - `vec3`

- `rgbm:vec4()`

  Returns vec4, where X, Y and Z are RGB values and W is mult.

  Returns:

    - `vec4`

# Module common/ac_primitive_quat.d.lua

## Function quat.new(x, y, z, w)
Creates new quaternion. It’s usually faster to create a new item with `quat(x, y, z, w)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  4. `w`: `number?`

  Returns:

  - `quat`
## Function quat.isquat(p)
Checks if value is quat or not.

  Parameters:

  1. `p`: `any`

  Returns:

  - `boolean`
## Function quat.fromAngleAxis(angle, x, y, z)
Creates a new quaternion.

  Parameters:

  1. `angle`: `number` In radians.

  2. `x`: `vec3|number`

  3. `y`: `number?`

  4. `z`: `number?`

  Returns:

  - `quat`
## Function quat.fromDirection(x, y, z)
Creates a new quaternion.

  Parameters:

  1. `x`: `vec3|number`

  2. `y`: `number?`

  3. `z`: `number?`

  Returns:

  - `quat`
## Function quat.between(u, v)
Creates a new quaternion.

  Parameters:

  1. `u`: `quat`

  2. `v`: `quat`

  Returns:

  - `quat`
## Function quat.tmp()
Temporary quaternion. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

  - `quat`
## Function quat(x, y, z, w)
Quaternion. All operators are overloaded.

  Parameters:

  1. `x`: `number?`

  2. `y`: `number?`

  3. `z`: `number?`

  4. `w`: `number?`

  Returns:

  - `quat`
## Class quat
Quaternion. All operators are overloaded.

- `quat.new(x, y, z, w)`

  Creates new quaternion. It’s usually faster to create a new item with `quat(x, y, z, w)` directly, but the way LuaJIT works,
that call only works with four numbers. If you only provide a single number, rest will be set to 0. This call, however, supports
various calls (which also makes it slightly slower).

  Parameters:

    1. `x`: `number?`

    2. `y`: `number?`

    3. `z`: `number?`

    4. `w`: `number?`

  Returns:

    - `quat`

- `quat.isquat(p)`

  Checks if value is quat or not.

  Parameters:

    1. `p`: `any`

  Returns:

    - `boolean`

- `quat.fromAngleAxis(angle, x, y, z)`

  Creates a new quaternion.

  Parameters:

    1. `angle`: `number` In radians.

    2. `x`: `vec3|number`

    3. `y`: `number?`

    4. `z`: `number?`

  Returns:

    - `quat`

- `quat.fromDirection(x, y, z)`

  Creates a new quaternion.

  Parameters:

    1. `x`: `vec3|number`

    2. `y`: `number?`

    3. `z`: `number?`

  Returns:

    - `quat`

- `quat.between(u, v)`

  Creates a new quaternion.

  Parameters:

    1. `u`: `quat`

    2. `v`: `quat`

  Returns:

    - `quat`

- `quat.tmp()`

  Temporary quaternion. For most cases though, it might be better to define those locally and use those. Less chance of collision.

  Returns:

    - `quat`

- `quat:clone()`

  Makes a copy of a quaternion.

  Returns:

    - `quat`

- `quat:unpack()`

  Unpacks quat into rgb and number.

  Returns:

    - `rgb`

- `quat:table()`

  Turns quat into a table with four values.

  Returns:

    - `number`

- `quat:type()`

  Returns reference to quat class.
function quat:type() end

- `quat:set(x, y, z, w)`

  Parameters:

    1. `x`: `quat|number`

    2. `y`: `number?`

    3. `z`: `number?`

    4. `w`: `number?`

  Returns:

    - `quat` Returns itself.

- `quat:setAngleAxis(angle, x, y, z)`

  Parameters:

    1. `angle`: `number` In radians.

    2. `x`: `vec3|number`

    3. `y`: `number?`

    4. `z`: `number?`

  Returns:

    - `quat` Returns itself.

- `quat:getAngleAxis()`

  Returns:

    1. `number` Angle in radians.

    2. `number` Axis, X.

    3. `number` Axis, Y.

    4. `number` Axis, Z.

- `quat:setBetween(u, v)`

  Parameters:

    1. `u`: `quat`

    2. `v`: `quat`

  Returns:

    - `quat` Returns itself.

- `quat:setDirection(x, y, z)`

  Parameters:

    1. `x`: `vec3|number`

    2. `y`: `number?`

    3. `z`: `number?`

  Returns:

    - `quat` Returns itself.

- `quat:add(valueToAdd, out)`

  Parameters:

    1. `valueToAdd`: `quat|number`

    2. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:sub(valueToSubtract, out)`

  Parameters:

    1. `valueToSubtract`: `quat|number`

    2. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:mul(valueToMultiplyBy, out)`

  Parameters:

    1. `valueToMultiplyBy`: `quat`

    2. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:scale(multiplier, out)`

  Parameters:

    1. `multiplier`: `number`

    2. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:length()`

  Returns:

    - `number`

- `quat:normalize(out)`

  Normalizes itself (unless different `out` is provided).

  Parameters:

    1. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:lerp(otherVector, mix, out)`

  Rewrites own values with values of lerp of itself and other quaternion (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `quat`

    2. `mix`: `number`

    3. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

- `quat:slerp(otherVector, mix, out)`

  Rewrites own values with values of slerp of itself and other quaternion (unless different `out` is provided).

  Parameters:

    1. `otherVector`: `quat`

    2. `mix`: `number`

    3. `out`: `quat|nil` Optional destination argument.

  Returns:

    - `quat` Returns itself or out value.

# Module ac_chaser_camera.lua

## Function ac.getCameraParameters(index)
Gets chase camera settings.
## Function ac.getJoystickLook()

  Returns:

  - `vec2`
## Class ScriptData

- `ScriptData.update(dt)`

  Called each frame.

  Parameters:

    1. `dt`: `number` Time passed since last `update()` call, in seconds.

# Module common/ac_audio.lua

## Function ac.AudioEvent(eventName, reverbResponse)
Create a new audio event from previously loaded soundbank.

  Parameters:

  1. `eventName`: `string` Event name, for example, `'/cars/lada_revolution/door'` (leading “/” or “event:” prefix are optional).

  2. `reverbResponse`: `boolean|`true`|`false`` Set to true if audio event should be affected by reverb in tunnels and such.

  Returns:

  - `ac.AudioEvent`
## Function ac.AudioEvent.fromFile(params, reverbResponse)
Create a new audio event from a file. Consequent calls with the same parameters would reuse previously loaded audio file.

  Parameters:

  1. `params`: `{filename: string, stream: {name: string, size: integer}, use3D: boolean, loop: boolean, insideConeAngle: number, outsideConeAngle: number, outsideVolume: number, minDistance: number, maxDistance: number, dopplerEffect: number, dsp: ac.AudioDSP[]}|"{\n`  filename = '',\n  stream = {\n    name = '',\n    size = 0\n  },\n  use3D = true,\n  loop = true\n}" "Table with properties:\n- `filename` (`string`): Audio filename.\n- `stream` (`{name: string, size: integer}`): Audio stream (as an alternative to `filename` for live streaming data using a memory mapped file).\n- `use3D` (`boolean`): Set to `false` to load audio without any 3D effects.\n- `loop` (`boolean`): Set to `false` to disable audio looping.\n- `insideConeAngle` (`number`): Angle in degrees at which audio is at 100% volume.\n- `outsideConeAngle` (`number`): Angle in degrees at which audio is at `outsideVolume` volume.\n- `outsideVolume` (`number`): Volume multiplier if listener is outside of the cone.\n- `minDistance` (`number`): Distance at which audio would stop going louder as it approaches listener (default is 1).\n- `maxDistance` (`number`): Distance at which audio would attenuating as it gets further away from listener (default is 10 km).\n- `dopplerEffect` (`number`): Scale for doppler effect.\n- `dsp` (`ac.AudioDSP[]`): IDs of DSPs to add."

  2. `reverbResponse`: `boolean|`true`|`false`` Set to true if audio event should be affected by reverb in tunnels and such.

  Returns:

  - `ac.AudioEvent`
## Class ac.AudioEvent
Audio event is a audio emitter which uses a certain event from one of loaded FMOD soundbanks.

- `ac.AudioEvent:setPosition(pos, dir, up, vel)`

  Sets audio event orientation.

  Parameters:

    1. `pos`: `vec3` Position. If you’re working on a car script, position is relative to car position.

    2. `dir`: `vec3|nil` Direction. If missing, forwards vector is used.

    3. `up`: `vec3|nil` Vector directed up for full 3D orientation.

    4. `vel`: `vec3|nil` Velocity of audio source. If missing, sound is stationary. If you’re working on a car script, velocity is relative to car velocity.

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:keepAlive()`

  Deprecated, now all events are alive until `:dispose()` is called.

- `ac.AudioEvent:setParam(name, value)`

  Set value of an audio event parameter.

  Parameters:

    1. `name`: `string`

    2. `value`: `number`

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:setDistanceMin(value)`

  Set minimum distance at which attenuation starts.

  Parameters:

    1. `value`: `number`

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:setDistanceMax(value)`

  Set maximum distance at which attenuation ends.

  Parameters:

    1. `value`: `number`

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:setConeSettings(inside, outside, outsideVolume)`

  Set 3D cone settings.

  Parameters:

    1. `inside`: `number?` Default value: 360.

    2. `outside`: `number?` Default value: 360.

    3. `outsideVolume`: `number?` Default value: 1.

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:setDSPParameter(dsp, key, value)`

  Set DSP parameter.

  Parameters:

    1. `dsp`: `integer` 0-based index of DSP.

    2. `key`: `integer` 0-based index of DSP parameter.

    3. `value`: `number`

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:isValid()`

  Returns `true` if event is loaded successfully. If event does not load, make sure soundbank is loaded first, and that event name is correct.

  Returns:

    - `boolean`

- `ac.AudioEvent:isPlaying()`

  Returns `true` if audio event is playing.

  Returns:

    - `boolean`

- `ac.AudioEvent:isPaused()`

  Returns `true` if audio event is paused.

  Returns:

    - `boolean`

- `ac.AudioEvent:isWithinRange()`

  Return `true` if audio event is within hearing range of current listener. Could be a good way to pause some expensive processing
for distant audio events. Although in general comparing distance with a threshold on Lua side with vectors might be faster (without
going Lua→CSP→FMOD and back).

  Returns:

    - `boolean`

- `ac.AudioEvent:resume()`

  function _ac_AudioEvent:resume() end

- `ac.AudioEvent:resumeIf(condition)`

  If condition is `true`, start an audio event if it’s stopped, resume it if it’s paused. If condition is false, stop audio event.

  Parameters:

    1. `condition`: `boolean|`true`|`false``

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:stop()`

  Stop audio event.

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:start()`

  Start audio event.

  Returns:

    - `ac.AudioEvent` Returns self for easy chaining.

- `ac.AudioEvent:getTransformationRaw()`

  If you need to move audio event often, accessing its matrix directly might be the best way. But you have to be extra careful in
making sure matrix is always normalized (vectors `side`, `up` and `look` should be othrogonal with lengths of 1), otherwise
audio might sound strange, with rapid changes in volume.

  Returns:

    - `mat4x4`

- `ac.AudioEvent:dispose()`

  Stop and remove audio event.
function _ac_AudioEvent:dispose() end

# Module wfx_common/ac_weatherconditions.lua

## Function ac.TrackConditions(sessionStart, sessionTransfer, randomness, lapGain)
State of the track surface.

  Parameters:

  1. `sessionStart`: `number` From 0 to 100.

  2. `sessionTransfer`: `number` From 0 to 100.

  3. `randomness`: `number`

  4. `lapGain`: `number`

  Returns:

  - `ac.TrackConditions`
## Class ac.TrackConditions
State of the track surface.
## Function ac.TemperatureParams(ambient, road)

  Parameters:

  1. `ambient`: `number` Temperature in C°.

  2. `road`: `number` Temperature in C°.

  Returns:

  - `ac.TemperatureParams`
## Class ac.TemperatureParams
## Function ac.WindParams(direction, speedFrom, speedTo)

  Parameters:

  1. `direction`: `number` Direction in degrees.

  2. `speedFrom`: `number` Speed in km/h.

  3. `speedTo`: `number` Speed in km/h.

  Returns:

  - `ac.WindParams`
## Class ac.WindParams
## Function ac.ConditionsSet()

  Returns:

  - `ac.ConditionsSet`
## Class ac.ConditionsSet