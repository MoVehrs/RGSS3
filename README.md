# RGSS3 Script Collection

## Project Overview

This repository contains a collection of custom Ruby scripts (RGSS3) designed for **RPG Maker VX Ace**. The scripts range from core system extensions and UI overhauls to specific feature additions and MKXP-Z compatibility layers.

The primary purpose of this collection is to provide modular, robust, and highly optimized components that can be used independently or in tandem to enhance the RPG Maker VX Ace engine. The scope includes dialog systems, window management, input tracking, and performance enhancements.

## Repository Structure

Currently, all scripts are located in the **root directory** of the repository for easy access. 

As the repository grows, the intended structure is to categorize scripts into logical folders (e.g., `systems/`, `ui/`, `mkxp-z/`, `addons/`).

## Usage Instructions

To use any of these scripts in your RPG Maker VX Ace project:

1.  Open your project in RPG Maker VX Ace.
2.  Open the **Script Editor** (F11).
3.  Scroll down to the **Materials** section (below `▼ Materials` and above `▼ Main Process`).
4.  Insert a new script slot.
5.  Copy the entire contents of the desired `.rb` file from this repository and paste it into the new script slot.
6.  Name the script slot according to the script (e.g., "Hammy - Window Headers").

**Dependencies:** 
*   Scripts containing `mkxp-z` in the name require the [MKXP-Z engine](https://github.com/mkxp-z/mkxp-z) to function correctly.
*   Scripts containing `yea` act as compatibility patches or integrations for Yanfly Engine Ace (YEA) scripts.
*   Check the header of each individual script for specific configuration instructions or prerequisite scripts.

## Script List

The scripts are logically grouped into the following categories:

### 1. Dialog & UI Systems
These scripts provide advanced dialog and user interface capabilities, heavily inspired by classic RPGs like Final Fantasy IX.
*   `vxa_hammy_ff9_choice_window.rb` - Provides an authentic Final Fantasy IX choice window system with enhanced features.
*   `vxa_hammy_ff9_dialog_system.rb` - Provides an authentic Final Fantasy IX dialog system featuring speech bubble positioning.
*   `vxa_hammy_ff9_popup_window.rb` - Provides an authentic Final Fantasy IX temporary popup window system for notifications.

### 2. Window Display & Aesthetics
Scripts focused on modifying the visual appearance of default windows.
*   `vxa_hammy_window_headers.rb` - Provides a customizable header system that automatically adds titles/graphics above windows.
*   `vxa_hammy_window_shadows.rb` - Provides a customizable dynamic shadow system that adds drop shadows behind windows.
*   `vxa_hammy_window_shadows_yea_system_options.rb` - Yanfly System Options integration for toggling window shadows.
*   `vxa_hammy_windowskin_system.rb` - Provides an authentic Final Fantasy IX windowskin system based on window class.
*   `vxa_hammy_windowskin_system_yea_system_options.rb` - Yanfly System Options integration for FF9 windowskin color selection.

### 3. Input & MKXP-Z Extensions
Scripts that leverage the MKXP-Z engine for enhanced input handling and native features.
*   `vxa_hammy_mkxp-z_input_constants.rb` - Exposes Windows Virtual-Key integer codes and SDL scancode symbol aliases as constants.
*   `vxa_hammy_mkxp-z_input_device_tracker.rb` - Tracks the active input device (Keyboard vs. Gamepad).
*   `vxa_hammy_mkxp-z_input_device_tracker_hud.rb` - Displays an on-screen HUD reflecting the active input device.
*   `vxa_hammy_mkxp-z_main_entry_point.rb` - Replaces the default Main script with improved error handling, resolution, and F12 reset for mkxp-z.
*   `vxa_hammy_mkxp-z_screenshot.rb` - Allows players to capture the current game screen and save it as a timestamped image file.

### 4. Pseudo-3D Vehicle Addons
Addons designed to expand upon Mode7 or Pseudo-3D vehicle implementations.
*   `vxa_hammy_vehicle_pseudo-3d_input_device_tracker.rb` - Input device tracker patch for WoodPenguin's Vehicle Pseudo-3D system.
*   `vxa_hammy_vehicle_pseudo-3d_interiors.rb` - Navigation system allowing players to enter vehicle interiors (cabins/holds).
*   `vxa_hammy_vehicle_pseudo-3d_performance_enhancements.rb` - Caching and pre-computation optimizations for WoodPenguin's Pseudo-3D engine.
*   `vxa_hammy_vehicle_pseudo-3d_widescreen_resolution.rb` - Eliminates tilemap cutoff bands at screen borders for widescreen resolutions.

### 5. Map Display & Enhancements
*   `vxa_hammy_simple_map_display_input_toggle.rb` - Allows cycling through map display modes via input for WoodPenguin's Simple Map Display.
*   `vxa_hammy_simple_map_display_performance_enhancements.rb` - Pre-computation strategy for marker rotation in WoodPenguin's Simple Map Display.

### 6. Core & Utilities
*   `vxa_hammy_disable_player_input.rb` - Simple toggle for disabling player movement input during events/cutscenes.
*   `vxa_hammy_menu_binding_patch.rb` - Rebinds the main menu away from the default :B button onto alternative configurable inputs.

## Compatibility

*   **Engine:** Designed exclusively for **RPG Maker VX Ace** (RGSS3).
*   **Ruby Version:** Written to conform to Ruby 1.9.2 standards used by the standard RMVXA engine, but fully compatible with modern **Ruby 3.1+** environments when used in conjunction with MKXP-Z.
*   **Limitations:** Certain scripts explicitly require the **MKXP-Z** custom executable. These will crash or fail to function if run on the standard `Game.exe`. Please read the script headers before implementation.

## License and Usage

This project is licensed under the **MIT License**.

You are free to use these scripts in any commercial or non-commercial RPG Maker VX Ace project. 

**Credit Expectations:** 
While the MIT license does not strictly mandate visible credits in your game, crediting **MoVehrs** in your game's credit roll or accompanying text file is highly appreciated.

## Contribution and Notes

This repository is actively maintained. Future updates will focus on standardizing script structures, improving documentation, and expanding compatibility features.

*   **Code Consistency:** Efforts are ongoing to standardize method names, formatting, and variable naming conventions across all scripts.
*   **Issues and Pull Requests:** If you encounter a bug or wish to propose an improvement, please open an issue or submit a pull request with a clear description of the changes.
