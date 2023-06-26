In this folder is documentation for Assetto Corsa CSP Lua API: definition files you can plug into
your text editor and see available functions, parameters they take, type of returned value, all
sorts of descriptions. Makes writing scripts a much easier and safer experience.

---------------------------------
| How to set it up in few steps |
---------------------------------

1. Install VS Code: https://code.visualstudio.com/

2. Open VS Code and install Lua extension by sumneko: go to File/Preferences/Extensions and 
  search for Lua, or go to https://marketplace.visualstudio.com/items?itemName=sumneko.lua and
  click “Install”.

3. Go to File/Preferences/Settings, search for “lua library”, find “Lua Workspace” option and 
  copy full path to one of folders inside “assettocorsa/extension/internal/lua-sdk” corresponding
  to the type of script you want to create.

  Alternatively, if you would want to create scripts of different types, you can install a custom
  extension “vs-code-extension.vsix” you can find next to this file. Simply go to 
  File/Preferences/Extensions, click on three dots, choose “Install from VSIX…” and select that
  file. This extension would scan folders in your current workspace opened in VS Code, detect
  the type of script you are working on, find AC root folder and automatically update library 
  path.

  For it to work though, you need to have a folder in a workspace which would contain folder with
  the script you are working on. For example, if you are working on car display scripts, it needs
  to be either in “…/content/cars/…” or in “…/extension/config/cars/…”. Check “rules.json” if you
  want to see other paths.

4. That’s all! Whole thing would activate automatically if you are editing Lua files, and help you
  by hinting about available functions and such.

  Please note: if you are working on car or track script, it wouldn’t work with INI files, but you
  can move script outside by replacing “SCRIPT='… your code …'” by “SCRIPT=some_file.lua” and 
  moving actual code to a file named “some_file.lua” next to the config.

5. If your Lua extension will complain about library files being too large, look for 
  “Lua.workspace.preloadFileSize” setting and increase its value to something like 1000 or 2000.

-----------------
|  More details |
-----------------

If you are using some IDE other than VS Code, definitions are prepared in EmmyLua format, so you
can go and search for a plugin for your IDE: https://github.com/EmmyLua.

There are also README files generated for each type of library, but at the moment they’re far 
from ideal.
