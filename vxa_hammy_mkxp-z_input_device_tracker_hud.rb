# encoding: utf-8
#==============================================================================
# ▼ Hammy - MKXP-Z Input Device Tracker HUD v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 15.05.2026
# -- Requires: mkxp-z (Ruby 3.1),
#              Hammy - MKXP-Z Input Device Tracker v1.00 or higher
# -- Recommended: None
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_mkxp_z_input_device_tracker_hud] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 15.05.2026 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an on-screen input device indicator HUD for RPG Maker
# VX Ace running on mkxp-z. It displays a small icon in the top-right corner
# of the screen reflecting the active input device tracked by the Input Device
# Tracker.
# 
# The system supports three configurable display modes, an optional battery
# level icon shown beside the device icon while a gamepad is active, an
# optional battery-driven device icon override, an optional wide keyboard
# indicator formed by two flush-adjacent icons, and per-scene suppression
# via a configurable scene list that can act as either a blacklist or a
# whitelist.
# 
# -----------------------------------------------------------------------------
# ► Input Device Tracker HUD Features
# -----------------------------------------------------------------------------
# ★ Top-right corner device icon reflecting the active input device
# ★ Three display modes via SHOW_BATTERY_ICON and BATTERY_CHANGES_DEVICE_ICON
# ★ Optional battery icon beside the device icon while a gamepad is active
# ★ Optional battery-driven device icon override for gamepad states
# ★ Optional wide keyboard indicator via a flush-adjacent secondary icon
# ★ Per-scene HUD suppression via configurable scene blacklist or whitelist
# ★ Switch-based HUD hide via a configurable game switch ID
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Scene_Base (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - start     → idt_hud_scene_base_start
#   - update    → idt_hud_scene_base_update
#   - terminate → idt_hud_scene_base_terminate
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events and other scripts.
# 
# -----------------------------------------------------------------------------
# ► HUD Visibility Control
# -----------------------------------------------------------------------------
# ★ $game_switches[Hammy::InputDeviceTrackerHUD::HIDE_SWITCH_ID] = true/false
#   Directly set the HUD hide switch state using the game switches array.
#   - true: Hides the HUD (all sprites become invisible)
#   - false: Shows the HUD normally
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains the three display modes and how to configure icons,
# margins, and scene exclusions.
# 
# -----------------------------------------------------------------------------
# ► Display Modes
# -----------------------------------------------------------------------------
# The HUD display mode is controlled by two booleans: SHOW_BATTERY_ICON and
# BATTERY_CHANGES_DEVICE_ICON. Only one mode is active at a time. When both
# are true, SHOW_BATTERY_ICON takes precedence.
# 
# ★ Default mode (both false): A single device icon is shown at all times.
#   The icon reflects the current device state using ICONS[:none],
#   ICONS[:keyboard], or ICONS[:gamepad].
# 
# ★ Battery icon mode (SHOW_BATTERY_ICON = true): A second battery icon is
#   drawn to the left of the screen edge beside the device icon while a
#   gamepad is active. The battery icon index is resolved from BATTERY_ICONS
#   by the current power_level symbol. When no gamepad is connected the
#   battery icon is hidden and the device icon shifts back to its
#   single-icon position automatically.
# 
# ★ Battery device icon mode (BATTERY_CHANGES_DEVICE_ICON = true): A single
#   icon is shown at all times. While a gamepad is active the icon index is
#   resolved from BATTERY_DEVICE_ICONS by the current power_level symbol
#   instead of the fixed ICONS[:gamepad] value. Non-gamepad states use ICONS
#   as usual.
# 
# -----------------------------------------------------------------------------
# ► Wide Keyboard Icon
# -----------------------------------------------------------------------------
# Setting ICONS[:keyboard_ext] to an integer icon index enables a wide
# keyboard indicator that occupies a 48×24 px region formed by two standard
# icons placed flush against each other with no margin between them. The
# extended icon is only shown while the active device is :keyboard. All other
# device states use the standard 24×24 single-icon layout.
# 
# ★ Set ICONS[:keyboard_ext] to nil (default) to keep the single 24×24 icon.
# 
# -----------------------------------------------------------------------------
# ► Switch-Based HUD Hide
# -----------------------------------------------------------------------------
# A single game switch can be used to hide the HUD at any time without
# removing it from the scene. The viewport and sprites persist; only their
# visibility is toggled, so the HUD reappears instantly when the switch is
# turned off again.
# 
# ★ Set HIDE_SWITCH_ID to any valid switch ID in your project.
#   - When this switch is ON, all HUD sprites are hidden.
#   - When this switch is OFF, the HUD displays normally.
# 
# ★ Usage via event command:
#   - Control Switches: Turn ON switch [HIDE_SWITCH_ID]  → hides the HUD
#   - Control Switches: Turn OFF switch [HIDE_SWITCH_ID] → shows the HUD
# 
# ★ Usage via script call:
#   - $game_switches[Hammy::InputDeviceTrackerHUD::HIDE_SWITCH_ID] = true
#   - $game_switches[Hammy::InputDeviceTrackerHUD::HIDE_SWITCH_ID] = false
# 
# ★ HUD suppression via SCENE_LIST takes priority over this switch.
#   In suppressed scenes the HUD is never created, so the switch has no effect.
# 
# -----------------------------------------------------------------------------
# ► Scene Exclusion / Inclusion
# -----------------------------------------------------------------------------
# SCENE_LIST holds scene class constants that control per-scene HUD
# visibility. Whether it acts as a blacklist or a whitelist is determined by
# SCENE_LIST_IS_WHITELIST. The HUD viewport and sprites are never created for
# suppressed scenes, so no update overhead is incurred.
# 
# ★ Blacklist mode (SCENE_LIST_IS_WHITELIST = false, default):
#   The HUD is shown in every scene EXCEPT those listed in SCENE_LIST.
#   An empty array means the HUD appears in every scene.
# 
# ★ Whitelist mode (SCENE_LIST_IS_WHITELIST = true):
#   The HUD is shown ONLY in scenes listed in SCENE_LIST. Every other
#   scene suppresses the HUD entirely.
#   An empty array means the HUD never appears in any scene.
# 
# ★ SCENE_LIST uses class constants directly, not strings.
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ This script requires Hammy - MKXP-Z Input Device Tracker and must be
#   placed BELOW it.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace running on mkxp-z.
# It will not run on default RPG Maker VX Ace without mkxp-z.
# 
#==============================================================================

#==============================================================================
# ** Input Device Tracker HUD Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Input Device Tracker HUD.
#==============================================================================

module Hammy
  module InputDeviceTrackerHUD
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Layout Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the spacing and render depth of the HUD icons.
    # 
    # MARGIN: Gap in pixels between icons and from the screen edges.
    #   Applied between the device icon and the battery icon when both are
    #   visible, and between the rightmost icon and the top-right screen edge.
    #   - Any non-negative integer
    #   - Default: 4
    # 
    # Z_LEVEL: Z-depth used for the HUD viewport and all HUD sprites.
    #   A very high value ensures the HUD renders above all scene content.
    #   - Any integer
    #   - Default: 9999
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    MARGIN = 4
    Z_LEVEL = 9999
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Display Mode Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure which display mode the HUD uses. See the General Setup &
    # Usage Guide for a full explanation of each mode.
    # 
    # SHOW_BATTERY_ICON: Shows a battery icon beside the device icon.
    #   When true, a second battery icon is drawn beside the device
    #   icon while a gamepad is active. Takes precedence over
    #   BATTERY_CHANGES_DEVICE_ICON when both are true.
    #   - true / false
    #   - Default: false
    # 
    # BATTERY_CHANGES_DEVICE_ICON: Replaces the device icon with a
    #   battery-level-specific icon while a gamepad is active.
    #   Only active when SHOW_BATTERY_ICON is false.
    #   - true / false
    #   - Default: true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SHOW_BATTERY_ICON = false
    BATTERY_CHANGES_DEVICE_ICON = true
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Scene Exclusion Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure which scenes suppress the HUD entirely. The HUD viewport
    # and sprites are never created for suppressed scenes.
    # 
    # SCENE_LIST_IS_WHITELIST: Controls how SCENE_LIST is interpreted.
    #   When false (blacklist), the HUD is shown in every scene except
    #   those listed in SCENE_LIST. When true (whitelist), the HUD is
    #   shown only in scenes listed in SCENE_LIST.
    #   - true / false
    #   - Default: false
    # 
    # SCENE_LIST: List of scene classes used as a blacklist or whitelist
    #   depending on SCENE_LIST_IS_WHITELIST (see above).
    #   - Array of scene class constants
    #   - Default: [Scene_Title, Scene_Menu]
    #   - Example: [Scene_Title, Scene_Menu, Scene_Gameover]
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SCENE_LIST_IS_WHITELIST = false
    SCENE_LIST = [Scene_Title, Scene_Menu].freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Switch Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the game switch used to hide the HUD at runtime.
    # 
    # HIDE_SWITCH_ID: Controls HUD visibility via a game switch.
    #   When this switch is ON, all HUD sprites are hidden. When OFF, the
    #   HUD displays normally. The viewport and sprites are kept alive while
    #   hidden so the HUD reappears instantly when the switch is turned off.
    #   - Any valid switch ID (1 to maximum switches in your project)
    #   - Default: 12
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    HIDE_SWITCH_ID = 12
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Icon Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the icon indices used by the HUD. All indices refer to the
    # Graphics/System/Iconset sheet using the standard 24×24 px icon grid
    # with 16 icons per row — the same layout as Window_Base#draw_icon.
    # 
    # ICONS: Primary device icon indices keyed by device state symbol.
    #   - none:         Icon shown when no device has been detected yet
    #   - keyboard:     Icon shown while the active device is :keyboard
    #   - keyboard_ext: Optional second icon rendered flush-right of the
    #                   keyboard icon to form a 48×24 wide indicator. Set
    #                   to nil to keep the standard 24×24 single icon.
    #   - gamepad:      Icon shown while the active device is :gamepad
    # 
    # BATTERY_ICONS: Battery state icon indices used in battery icon mode.
    #   Keys match the symbols returned by Input::Controller.power_level.
    #   Only active when SHOW_BATTERY_ICON is true.
    # 
    # BATTERY_DEVICE_ICONS: Device icon overrides per battery state.
    #   Applied only while the active device is :gamepad. Only active
    #   when BATTERY_CHANGES_DEVICE_ICON is true.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ICONS = {
      none:         0,
      keyboard:     1,
      keyboard_ext: nil,
      gamepad:      2,
    }.freeze
    
    BATTERY_ICONS = {
      WIRED:   3,
      MAX:     4,
      HIGH:    5,
      MEDIUM:  6,
      LOW:     7,
      EMPTY:   8,
      UNKNOWN: 9,
    }.freeze
    
    BATTERY_DEVICE_ICONS = {
      WIRED:   10,
      MAX:     11,
      HIGH:    12,
      MEDIUM:  13,
      LOW:     14,
      EMPTY:   15,
      UNKNOWN: 16,
    }.freeze
    
    #==========================================================================
    # ▼ End of Documentation
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # This marks the end of the documentation and configuration section.
    # Everything below this point is the actual script implementation code.
    # 
    # WARNING: Modifying the code below requires advanced Ruby and RGSS3
    # knowledge. Improper changes may cause script errors, game crashes, or
    # data corruption. Only edit if you understand the consequences and have
    # backups of your project.
    #==========================================================================
    
    #------------------------------------------------------------------------
    # * Module Extension
    #------------------------------------------------------------------------
    extend self
    
    #------------------------------------------------------------------------
    # * Determine if HUD is Hidden via Game Switch
    #------------------------------------------------------------------------
    def _hud_hidden?
      $game_switches && $game_switches[HIDE_SWITCH_ID]
    end
    
    #------------------------------------------------------------------------
    # * Determine if Scene is Suppressed from HUD Display
    #------------------------------------------------------------------------
    def _excluded_scene?(scene)
      listed = SCENE_LIST.include?(scene.class)
      SCENE_LIST_IS_WHITELIST ? !listed : listed
    end
    
    #------------------------------------------------------------------------
    # * Create HUD Viewport and Sprites
    #     scene : The current scene instance
    #------------------------------------------------------------------------
    def create_hud(scene)
      return if _excluded_scene?(scene)
      
      @hud_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @hud_viewport.z = Z_LEVEL
      
      @hud_sprite = Sprite.new(@hud_viewport)
      @hud_sprite.z = Z_LEVEL
      
      @keyboard_ext_sprite = nil
      if ICONS[:keyboard_ext]
        @keyboard_ext_sprite   = Sprite.new(@hud_viewport)
        @keyboard_ext_sprite.z = Z_LEVEL
        @keyboard_ext_sprite.y = MARGIN
        @keyboard_ext_sprite.visible = false
      end
      
      @battery_sprite = nil
      
      if SHOW_BATTERY_ICON
        @battery_sprite   = Sprite.new(@hud_viewport)
        @battery_sprite.z = Z_LEVEL
      end
      
      @last_device  = nil
      @last_battery = nil
      @last_hidden  = nil
      
      _refresh_bitmaps
    end
    
    #------------------------------------------------------------------------
    # * Update HUD Icons
    #------------------------------------------------------------------------
    def update_hud
      return unless @hud_sprite && !@hud_sprite.disposed?
      
      hidden = _hud_hidden?
      
      if hidden != @last_hidden
        @hud_viewport.visible = !hidden
        @last_hidden = hidden
      end
      
      return if hidden
      
      current_device  = Hammy::InputDeviceTracker.device
      current_battery = _read_battery_level
      
      return if current_device  == @last_device &&
                current_battery == @last_battery
      
      _refresh_bitmaps(current_device, current_battery)
    end
    
    #------------------------------------------------------------------------
    # * Free HUD Sprites and Viewport
    #------------------------------------------------------------------------
    def terminate_hud
      _dispose_sprite(@hud_sprite)
      _dispose_sprite(@keyboard_ext_sprite)
      _dispose_sprite(@battery_sprite)
      
      @hud_viewport.dispose if @hud_viewport && !@hud_viewport.disposed?
      
      @hud_sprite = nil
      @keyboard_ext_sprite = nil
      @battery_sprite = nil
      @hud_viewport = nil
      @last_device = nil
      @last_battery = nil
      @last_hidden = nil
    end
    
    #------------------------------------------------------------------------
    # * Free Sprite and Its Bitmap
    #     sprite : Target sprite to dispose
    #------------------------------------------------------------------------
    def _dispose_sprite(sprite)
      return unless sprite && !sprite.disposed?
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose
    end
    
    #------------------------------------------------------------------------
    # * Get Current Battery Level
    #------------------------------------------------------------------------
    def _read_battery_level
      return nil unless SHOW_BATTERY_ICON || BATTERY_CHANGES_DEVICE_ICON
      return nil unless Input::Controller.connected?
      Input::Controller.power_level
    end
    
    #------------------------------------------------------------------------
    # * Get Icon Index for Device Sprite
    #     device  : Active device symbol (:none, :keyboard, :gamepad)
    #     battery : Current battery level symbol, or nil
    #------------------------------------------------------------------------
    def _device_icon_index(device, battery)
      if !SHOW_BATTERY_ICON && BATTERY_CHANGES_DEVICE_ICON &&
         device == :gamepad && battery
        BATTERY_DEVICE_ICONS[battery] || BATTERY_DEVICE_ICONS[:UNKNOWN]
      else
        ICONS[device] || ICONS[:none]
      end
    end
    
    #------------------------------------------------------------------------
    # * Get Icon Index for Battery Sprite
    #     device  : Active device symbol (:none, :keyboard, :gamepad)
    #     battery : Current battery level symbol, or nil
    #------------------------------------------------------------------------
    def _battery_icon_index(device, battery)
      return nil unless SHOW_BATTERY_ICON
      return nil unless device == :gamepad && battery
      BATTERY_ICONS[battery] || BATTERY_ICONS[:UNKNOWN]
    end
    
    #------------------------------------------------------------------------
    # * Determine if Wide Keyboard Icon is Active
    #------------------------------------------------------------------------
    def _keyboard_extended?(device)
      device == :keyboard && !ICONS[:keyboard_ext].nil? &&
        @keyboard_ext_sprite && !@keyboard_ext_sprite.disposed?
    end
    
    #------------------------------------------------------------------------
    # * Refresh Sprite Bitmaps
    #     device  : Active device symbol (:none, :keyboard, :gamepad)
    #     battery : Current battery level symbol, or nil
    #------------------------------------------------------------------------
    def _refresh_bitmaps(device = nil, battery = nil)
      device  ||= Hammy::InputDeviceTracker.device
      battery ||= _read_battery_level
      
      wide_keyboard = _keyboard_extended?(device)
      device_block_width = wide_keyboard ? 48 : 24
      
      battery_idx = _battery_icon_index(device, battery)
      battery_visible = !battery_idx.nil?
      
      total_width = device_block_width +
                    (battery_visible ? MARGIN + 24 : 0)
      
      device_left_x = Graphics.width - total_width - MARGIN
      
      @hud_sprite.x = device_left_x
      @hud_sprite.y = MARGIN
      _draw_icon_to_sprite(@hud_sprite, _device_icon_index(device, battery))
      
      if @keyboard_ext_sprite && !@keyboard_ext_sprite.disposed?
        if wide_keyboard
          @keyboard_ext_sprite.x       = device_left_x + 24
          @keyboard_ext_sprite.visible = true
          _draw_icon_to_sprite(@keyboard_ext_sprite, ICONS[:keyboard_ext])
        else
          @keyboard_ext_sprite.visible = false
          if @keyboard_ext_sprite.bitmap && !@keyboard_ext_sprite.bitmap.disposed?
            @keyboard_ext_sprite.bitmap.dispose
            @keyboard_ext_sprite.bitmap = nil
          end
        end
      end
      
      if @battery_sprite && !@battery_sprite.disposed?
        if battery_visible
          @battery_sprite.x       = Graphics.width - 24 - MARGIN
          @battery_sprite.y       = MARGIN
          @battery_sprite.visible = true
          _draw_icon_to_sprite(@battery_sprite, battery_idx)
        else
          @battery_sprite.visible = false
          
          if @battery_sprite.bitmap && !@battery_sprite.bitmap.disposed?
            @battery_sprite.bitmap.dispose
            @battery_sprite.bitmap = nil
          end
        end
      end
      
      @last_device  = device
      @last_battery = battery
    end
    
    #------------------------------------------------------------------------
    # * Draw Icon onto Sprite Bitmap
    #     sprite     : Target sprite to draw onto
    #     icon_index : Index of the icon in the Iconset
    #------------------------------------------------------------------------
    def _draw_icon_to_sprite(sprite, icon_index)
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      
      iconset  = Cache.system("Iconset")
      src_rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      
      bmp = Bitmap.new(24, 24)
      bmp.blt(0, 0, iconset, src_rect)
      
      sprite.bitmap = bmp
    end
    
  end # InputDeviceTrackerHUD
end # Hammy

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :idt_hud_scene_base_start, :start unless $@
  alias_method :idt_hud_scene_base_update, :update unless $@
  alias_method :idt_hud_scene_base_terminate, :terminate unless $@
  
  #--------------------------------------------------------------------------
  # * Start Processing                                                [Alias]
  #--------------------------------------------------------------------------
  def start
    idt_hud_scene_base_start
    Hammy::InputDeviceTrackerHUD.create_hud(self)
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    idt_hud_scene_base_update
    Hammy::InputDeviceTrackerHUD.update_hud
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing                                          [Alias]
  #--------------------------------------------------------------------------
  def terminate
    Hammy::InputDeviceTrackerHUD.terminate_hud
    idt_hud_scene_base_terminate
  end
  
end # Scene_Base

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
