# Assetto Corsa Lua Scripts by ACP

A collection of Lua scripts for Assetto Corsa to enhance the gameplay experience with new features and functionalities. These scripts add a variety of new gameplay elements, including missions, a police chase system, and various utility functions to improve the overall experience.

## How to Set Up

To use these scripts, you need to have the latest version of Custom Shaders Patch (CSP) installed in Assetto Corsa.

1.  Download the scripts from this repository.
2.  Place the script files (`ACP_Essential.lua`, `ACP_Police.lua`, `ACP_Utils.lua`) into the `apps/lua` folder of your Assetto Corsa installation directory.
3.  The scripts will be automatically loaded when you start a session in Assetto Corsa.

---

## The Scripts

### Script 1: `ACP_Essential.lua`

**Script description:**

This script is the core of the ACP scripts collection. It provides essential functionalities such as player data management, settings, missions, and a user interface for interacting with the various features.

**Functions, constants, references, keys bound:**

*   **Constants:** `STEAMID`, `CSP_VERSION`, `CAR_ID`, `CAR_NAME`, `DRIVER_NAME`, `SHARED_PLAYER_DATA`, `SHARED_EVENT_KEY`, `GOOGLE_APP_SCRIPT_URL`, `FIREBASE_URL`, and various UI and game-related constants.
*   **Functions:**
    *   `loadImages(key)`: Loads images for the UI.
    *   `formatTime(time, format)`: Formats time into a readable string.
    *   `isPoliceCar(carID)`: Checks if a car is a police car.
    *   `hasKeys(keys, t)`: Checks if a table has all the specified keys.
    *   `truncate(number, decimal)`: Truncates a number to a specified number of decimal places.
    *   `tableToVec3(t)`, `tableToVec2(t)`, `tableToRGBM(t)`: Converts tables to vectors and colors.
    *   `canProcessRequest(err, response)`: Checks if a web request can be processed.
    *   `hasExistingData(response)`: Checks if a web response has existing data.
    *   `snapToTrack(v)`: Snaps a vector to the track.
    *   `sortLeaderboard(category, rows)`: Sorts a leaderboard.
    *   `Leaderboard.allocate(name)`, `Leaderboard.tryParse(name, data)`, `Leaderboard.fetch(name)`: Manages leaderboards.
    *   `Settings.new()`, `Settings.tryParse(data)`, `Settings.fetch(url, callback)`, `Settings.allocate(callback)`, `Settings:export()`, `Settings:save()`: Manages player settings.
    *   `Gate.tryParse(data)`, `Gate.allocate(data)`, `Gate:isTooFar()`, `Gate:isCrossed()`: Manages mission gates.
    *   `Sector.tryParse(data)`, `Sector.fetch(url, callback)`, `Sector.allocate(name, callback)`, `Sector:reset()`, `Sector:starting()`, `Sector:isFinished()`, `Sector:hasStarted()`, `Sector:updateTime()`, `Sector:isUnderTimeLimit()`, `Sector:updateTimeColor()`, `Sector:update()`: Manages mission sectors.
    *   `SectorStats.tryParse(name, data)`, `SectorStats.allocate(name, data)`, `SectorStats:addRecord(time)`, `SectorStats:export()`: Manages sector statistics.
    *   `Player.new()`, `Player.tryParse(data)`, `Player.fetch(url, callback)`, `Player.allocate(callback)`, `Player:sortSectors()`, `Player:export()`, `Player:save()`, `Player:addSectorRecord(sectorName, time)`: Manages player data.
    *   `SectorManager.new()`, `SectorManager.allocate()`, `SectorManager:reset()`, `SectorManager:setSector(name)`: Manages the current sector.
    *   `calculateElo(opponentElo, youWon)`: Calculates Elo rating changes.
*   **Key Bindings:**
    *   `ac.ControlButton('__ACP_OPEN_MENU_KEY_BIND', ui.KeyIndex.M)`: Opens the main menu.

### Script 2: `ACP_Police.lua`

**Script description:**

This script adds a police chase system to the game. It allows players to take on the role of the police and chase down suspects. It includes features such as a police HUD, a radar system, and the ability to arrest suspects.

**Functions, constants, references, keys bound:**

*   **Constants:** `POLICE_CAR`, `CAMERAS`, `MSG_ARREST`, `MSG_LOST`, `MSG_ENGAGE`, and various UI and game-related constants.
*   **Functions:**
    *   `isPoliceCar(carID)`: Checks if a car is a police car.
    *   `loadImages(key)`: Loads images for the UI.
    *   `formatMessage(message)`: Formats a message with suspect information.
    *   `playerSelected(suspect)`: Selects a player as a suspect.
    *   `lostSuspect()`: Handles the logic for when a suspect is lost.
    *   `arrestSuspect()`: Handles the logic for when a suspect is arrested.
    *   `chaseUpdate()`: Updates the chase logic.
    *   `radarUpdate()`: Updates the radar logic.
*   **Key Bindings:** None.

### Script 3: `ACP_Utils.lua`

**Script description:**

This script provides various utility functions that are used by the other scripts. It includes functions for formatting time, managing player data, and handling fuel.

**Functions, constants, references, keys bound:**

*   **Constants:** `GAS_STATIONS`, `CREW_PREFIX`, `CAR_NAMES`, and various UI and game-related constants.
*   **Functions:**
    *   `formatTime(time, format)`: Formats time into a readable string.
    *   `truncate(number, decimal)`: Truncates a number to a specified number of decimal places.
    *   `isPoliceCar(carID)`: Checks if a car is a police car.
    *   `updatedSharedData()`: Updates the shared player data.
    *   `isAtGasStation()`: Checks if the player is at a gas station.
    *   `fillCarWithFuel()`: Fills the car with fuel.
    *   `fuelWarning()`: Displays a warning when the fuel is low.
    *   `applySkinToCar(carId, url)`: Applies a skin to a car.
*   **Key Bindings:** None.
