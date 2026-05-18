# frozen_string_literal: true
# encoding: utf-8
#==============================================================================
# ▼ Hammy - MKXP-Z Screenshot v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 17.05.2026
# -- Requires: mkxp-z (Ruby 3.1)
# -- Optional: Hammy - MKXP-Z Input Constants v1.00
# -- Recommended: Hammy - Yanfly System Options - Date Format Addon v1.00
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_mkxp_z_screenshot] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 17.05.2026 - Initial release. (v1.00)
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a screenshot capture system for RPG Maker VX Ace
# running on mkxp-z. It allows players to capture the current game screen
# and save it as a timestamped image file.
# 
# The system supports configurable keyboard and controller triggers,
# configurable output folder, filename, and file format settings, European
# and American timestamp formats, optional sound effect playback, and
# collision-free filename generation with automatic counter suffixes.
# 
# -----------------------------------------------------------------------------
# ► Core Screenshot Features
# -----------------------------------------------------------------------------
# ★ One-press screenshot capture with Graphics.screenshot
# ★ Configurable keyboard and optional controller triggers
# ★ Automatic screenshot folder creation on first use
# ★ Timestamped filenames with collision-safe counter suffixes
# ★ European and American timestamp format support
# ★ Optional sound effect playback after capture
# ★ Configurable filename template and image file format
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► SceneManager (Module/Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - run → mkxpz_screenshot_scenemanager_run
# 
# -----------------------------------------------------------------------------
# ► Scene_Base (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - update_basic → mkxpz_screenshot_sc_bs_update_basic
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains when screenshots are captured and how saved files are
# named.
# 
# -----------------------------------------------------------------------------
# ► Screenshot Capture
# -----------------------------------------------------------------------------
# The screenshot check runs once per frame from Scene_Base after the normal
# basic scene update. When the configured trigger fires, the current game screen
# is captured through Graphics.screenshot and written to disk immediately.
# 
# ★ The default keyboard trigger is :F8.
# ★ A separate controller trigger can be enabled for SDL controller buttons.
# ★ Do not add a separate controller trigger for RGSS action buttons that
#   already map to controller input through Input.trigger?.
# 
# -----------------------------------------------------------------------------
# ► File Output
# -----------------------------------------------------------------------------
# The screenshot folder is created during startup before gameplay begins. Each
# capture uses the configured filename template to combine the output folder,
# base filename, timestamp, collision counter, and file extension.
# 
# ★ Existing files are never overwritten; a numeric counter suffix is added
#   when the generated filename is already taken.
# ★ The image encoder is selected by the configured file extension.
# ★ An optional sound effect can be played after a successful capture.
# 
# -----------------------------------------------------------------------------
# ► Date Format Behavior
# -----------------------------------------------------------------------------
# If $game_system.european_format is available, its runtime value controls
# which timestamp format is used. Otherwise, the script falls back to the
# configured default format.
# 
# ★ The optional Date Format Addon provides $game_system.european_format.
# ★ Both timestamp layouts are configured separately in the settings below.
# 
#==============================================================================
# ▼ Recommended Scripts
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script is recommended for regional date format selection:
# 
# -----------------------------------------------------------------------------
# ► Hammy - Yanfly System Options - Date Format Addon
# -----------------------------------------------------------------------------
# Adds a date format toggle to Yanfly System Options for regional timestamp
# preferences.
# 
# ★ Benefits for MKXP-Z Screenshot:
#   - Lets players choose the screenshot timestamp format from the options menu
#   - Provides $game_system.european_format for runtime date format selection
#   - Avoids relying only on the fallback date format constant
# 
# ★ Installation: Place this script ABOVE the Screenshot script.
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ If using Hammy - MKXP-Z Input Constants, place this script BELOW it.
# 
# ★ If using Hammy - Yanfly System Options - Date Format Addon, place this
#   script BELOW it.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace running on mkxp-z.
# It will not run on default RPG Maker VX Ace without mkxp-z.
# 
#==============================================================================

#==============================================================================
# ** MKXP-Z Screenshot Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the MKXP-Z Screenshot system.
#==============================================================================

module Hammy
  module MkxpzScreenshot
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Trigger Key -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the keyboard key used to capture a screenshot.
    # 
    # SCREENSHOT_KEY: Keyboard key used as the screenshot trigger.
    #   Bare RGSS3 symbols are routed through Input.trigger?. Tagged arrays
    #   can force routing with [:rgss, :SYM] or [:sdl, :SYM]. SDL routing
    #   and bare VK integers are mkxp-z only and use Input.triggerex?.
    #   - RGSS symbol, tagged array, or VK integer
    #   - Default: :F8
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SCREENSHOT_KEY    = :F8
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Controller Button (mkxp-z only) -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the controller button used to capture a screenshot on mkxp-z.
    # 
    # SCREENSHOT_BUTTON: Controller button used as the screenshot trigger.
    #   Only needed when SCREENSHOT_KEY has no default controller binding,
    #   such as :F8, an SDL-only key, or a raw VK integer. Set to nil to
    #   disable the separate controller trigger.
    #   - Any controller button symbol, or nil
    #   - Default: nil
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SCREENSHOT_BUTTON = nil
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - File Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure where screenshots are saved and which image format is used.
    # 
    # FOLDER_NAME: Folder used for saved screenshots.
    #   Created automatically during startup if it does not already exist.
    #   - Folder name or relative folder path
    #   - Default: "Screenshots"
    # 
    # BASE_FILENAME: Base name used for generated screenshot filenames.
    #   Combined with timestamp and collision counter by FILENAME_TEMPLATE.
    #   - String
    #   - Default: "screenshot"
    # 
    # FILE_EXTENSION: Image file extension used by Graphics.screenshot.
    #   mkxp-z automatically selects the encoder based on this extension.
    #   - "png", "jpg", or "bmp"
    #   - Default: "png"
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    FOLDER_NAME    = "Screenshots"
    BASE_FILENAME  = "screenshot"
    FILE_EXTENSION = "png"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Timestamp & Filename Format -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the timestamp text and final screenshot filename structure.
    # 
    # EU_TIMESTAMP_FORMAT: Timestamp format used for European date order.
    #   Uses standard Ruby Time#strftime directives.
    #   - String
    #   - Default: "%d-%m-%Y_%H-%M-%S"
    # 
    # US_TIMESTAMP_FORMAT: Timestamp format used for American date order.
    #   Uses standard Ruby Time#strftime directives.
    #   - String
    #   - Default: "%Y-%m-%d_%H-%M-%S"
    # 
    # FILENAME_TEMPLATE: Final path template for saved screenshots.
    #   Available placeholders are %{dir}, %{base}, %{time}, %{counter},
    #   and %{ext}. The counter placeholder is empty unless a filename
    #   collision is detected.
    #   - String using the placeholders above
    #   - Default: "%{dir}/%{base}_%{time}%{counter}.%{ext}"
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    EU_TIMESTAMP_FORMAT = "%d-%m-%Y_%H-%M-%S"
    US_TIMESTAMP_FORMAT = "%Y-%m-%d_%H-%M-%S"
    FILENAME_TEMPLATE   = "%{dir}/%{base}_%{time}%{counter}.%{ext}"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Date Format Fallback -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the fallback date order used when no runtime setting exists.
    # 
    # FORCE_EUROPEAN_FORMAT: Controls the fallback timestamp date order.
    #   Only used when $game_system.european_format is unavailable.
    #   - true: Use EU_TIMESTAMP_FORMAT
    #   - false: Use US_TIMESTAMP_FORMAT
    #   - Default: false
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    FORCE_EUROPEAN_FORMAT = false
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Sound Effect Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the sound effect played after a screenshot is captured.
    # 
    # PLAY_SOUND: Enables or disables screenshot sound playback.
    #   - true / false
    #   - Default: true
    # 
    # SOUND_NAME: SE filename from the Audio/SE folder.
    #   Do not include the file extension.
    #   - String
    #   - Default: "Decision1"
    # 
    # SOUND_VOLUME: Playback volume for the screenshot sound effect.
    #   - 0 to 100
    #   - Default: 80
    # 
    # SOUND_PITCH: Playback pitch for the screenshot sound effect.
    #   - 50 to 150
    #   - Default: 100
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    PLAY_SOUND   = true
    SOUND_NAME   = "Decision1"
    SOUND_VOLUME = 80
    SOUND_PITCH  = 100
    
    #========================================================================
    # ▼ End of Configuration
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # Everything below this point is the actual script implementation code.
    #
    # WARNING: Modifying the code below requires advanced Ruby and RGSS3
    # knowledge. Improper changes may cause script errors, game crashes, or
    # data corruption. Only edit if you understand the consequences and have
    # backups of your project.
    #========================================================================
    
    #------------------------------------------------------------------------
    # * Instance Variables
    #------------------------------------------------------------------------
    @initialized = false
    
    #------------------------------------------------------------------------
    # * Module Extension
    #------------------------------------------------------------------------
    extend self
    
    #------------------------------------------------------------------------
    # * Initialize Module
    #------------------------------------------------------------------------
    def initialize
      return if @initialized
      Dir.mkdir(FOLDER_NAME) unless File.exist?(FOLDER_NAME)
      @initialized = true
    end
    
    #------------------------------------------------------------------------
    # * Frame Update
    #------------------------------------------------------------------------
    def update
      initialize unless @initialized
      return unless _screenshot_triggered?
      _take_screenshot
    end
    
    #------------------------------------------------------------------------
    # * Determine if Screenshot is Triggered
    #------------------------------------------------------------------------
    def _screenshot_triggered?
      _keyboard_triggered? || _controller_triggered?
    end
    
    #------------------------------------------------------------------------
    # * Determine if Keyboard Key is Triggered
    #------------------------------------------------------------------------
    def _keyboard_triggered?
      key = SCREENSHOT_KEY
      if key.is_a?(Integer)
        Input.triggerex?(key)
      elsif key.is_a?(Array)
        tag, val = key
        tag == :rgss ? Input.trigger?(val) : Input.triggerex?(val)
      else
        Input.trigger?(key)
      end
    end
    
    #------------------------------------------------------------------------
    # * Determine if Controller Button is Triggered
    #------------------------------------------------------------------------
    def _controller_triggered?
      return false if SCREENSHOT_BUTTON.nil?
      Input::Controller.connected? &&
        Input::Controller.triggerex?(SCREENSHOT_BUTTON)
    end
    
    #------------------------------------------------------------------------
    # * Capture Screenshot
    #------------------------------------------------------------------------
    def _take_screenshot
      european = $game_system.respond_to?(:european_format) ?
        $game_system.european_format : FORCE_EUROPEAN_FORMAT
      
      timestamp = Time.now.strftime(
        european ? EU_TIMESTAMP_FORMAT : US_TIMESTAMP_FORMAT
      )
      
      counter = 0
      full_path = nil
      
      loop do
        counter_suffix = counter == 0 ? "" : "_#{counter}"
        
        full_path = FILENAME_TEMPLATE % {
          dir:     FOLDER_NAME,
          base:    BASE_FILENAME,
          time:    timestamp,
          counter: counter_suffix,
          ext:     FILE_EXTENSION
        }
        
        break unless File.exist?(full_path)
        counter += 1
      end
      
      Graphics.screenshot(full_path)
      
      RPG::SE.new(
        SOUND_NAME,
        SOUND_VOLUME,
        SOUND_PITCH
      ).play if PLAY_SOUND
    end
    
  end # MkxpzScreenshot
end # Hammy

#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
# This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

class << SceneManager
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :mkxpz_screenshot_scenemanager_run, :run unless $@
  
  #--------------------------------------------------------------------------
  # * Execute                                                         [Alias]
  #--------------------------------------------------------------------------
  def run
    Hammy::MkxpzScreenshot.initialize
    mkxpz_screenshot_scenemanager_run
  end
  
end # SceneManager

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
# This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :mkxpz_screenshot_sc_bs_update_basic, :update_basic unless $@
  
  #--------------------------------------------------------------------------
  # * Update Frame (Basic)                                            [Alias]
  #--------------------------------------------------------------------------
  def update_basic
    mkxpz_screenshot_sc_bs_update_basic
    Hammy::MkxpzScreenshot.update
  end
  
end # Scene_Base

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
