# encoding: utf-8
#==============================================================================
# ▼ Hammy - MKXP-Z Input Device Tracker v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: mkxp-z (Ruby 3.1)
# -- Recommended: None
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_mkxp_z_input_device_tracker] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 25.05.2026 - (v1.01) Applied new documentation conventions.
# 
# 15.05.2026 - (v1.00) Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an input device tracking system for RPG Maker VX Ace
# running on mkxp-z. It detects whether the player is using a keyboard or a
# gamepad and exposes that state as a queryable symbol: :none, :keyboard, or
# :gamepad.
# 
# The system supports per-frame device polling, gamepad button detection via
# the SDL controller API, keyboard detection via the mkxp-z raw key state
# array, gamepad priority over simultaneous keyboard input, and memoized API
# availability checks to avoid repeated reflection overhead.
# 
# -----------------------------------------------------------------------------
# ► Input Device Tracker Features
# -----------------------------------------------------------------------------
# ★ Queryable active device state as a symbol (:none, :keyboard, :gamepad)
# ★ Gamepad detection via SDL controller button polling (buttons 0-14)
# ★ Keyboard detection via mkxp-z native raw key state array
# ★ Gamepad input takes priority over simultaneous keyboard input
# ★ API availability checked once at startup and cached for process lifetime
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Scene_Base (Class)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update_basic
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events and other scripts.
# 
# -----------------------------------------------------------------------------
# ► Device State
# -----------------------------------------------------------------------------
# ★ Hammy::InputDeviceTracker.device
#   Returns the current device symbol: :none, :keyboard, or :gamepad.
#   - Parameters: None
#   - Returns: Symbol
# 
# ★ Hammy::InputDeviceTracker.keyboard?
#   Returns true when the active device is :keyboard.
#   - Parameters: None
#   - Returns: Boolean
# 
# ★ Hammy::InputDeviceTracker.gamepad?
#   Returns true when the active device is :gamepad.
#   - Parameters: None
#   - Returns: Boolean
# 
# ★ Hammy::InputDeviceTracker.none?
#   Returns true when no device has been detected yet (:none).
#   - Parameters: None
#   - Returns: Boolean
# 
# ★ Hammy::InputDeviceTracker.reset
#   Resets the device state back to :none.
#   - Parameters: None
#   - Returns: Nil
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains how device detection works and how to query the active
# device state from other scripts or events.
# 
# -----------------------------------------------------------------------------
# ► Detection Strategy
# -----------------------------------------------------------------------------
# The tracker polls for gamepad input first on every frame. If any SDL
# controller button is held, the device switches to :gamepad regardless of any
# simultaneous keyboard activity. Keyboard input is only registered when no
# gamepad button is active. The device state remains at its last detected value
# until a different device fires.
# 
# ★ Gamepad input takes priority over keyboard input at all times.
# 
# ★ The device state does not revert automatically when input stops.
# 
# ★ Only digital buttons (0-14) are polled. Analog stick movement and trigger
#   axis input do not register as gamepad activity.
# 
# ★ Call Hammy::InputDeviceTracker.reset to return the state to :none manually.
# 
# -----------------------------------------------------------------------------
# ► API Availability
# -----------------------------------------------------------------------------
# Both the controller API and the keyboard API are mkxp-z exclusive. Their
# availability is checked once at startup and memoized for the lifetime of the
# process. If either API is absent, the corresponding detection path is skipped
# silently and the tracker stays at :none.
# 
# ★ This script requires mkxp-z and will not function on standard RGSS3.
# 
# ★ Missing APIs produce no errors; the tracker simply stays at :none.
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace running on mkxp-z
# (Ruby 3.1). It will not run on default RPG Maker VX Ace without mkxp-z.
# 
#==============================================================================

#==============================================================================
# ▼ End of Documentation
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This marks the end of the documentation and configuration section. Everything
# below this point is the actual script implementation code.
# 
# WARNING: Modifying the code below requires advanced Ruby and RGSS3 knowledge.
# Improper changes may cause script errors, game crashes, or data corruption.
# Only edit if you understand the consequences and have backups of your project.
#==============================================================================

#==============================================================================
# ** Hammy::InputDeviceTracker
#------------------------------------------------------------------------------
#  This module tracks the active input device and exposes its state as a
# symbol. It is updated every frame via Scene_Base#update_basic.
#==============================================================================

module Hammy
  module InputDeviceTracker
    #--------------------------------------------------------------------------
    # * Constants (Gamepad Buttons)
    #--------------------------------------------------------------------------
    GAMEPAD_BUTTONS = (0..14).freeze
    
    #------------------------------------------------------------------------
    # * Module Extension
    #------------------------------------------------------------------------
    extend self
    
    #------------------------------------------------------------------------
    # * Get Current Device
    #------------------------------------------------------------------------
    def device
      @device ||= :none
    end
    
    #------------------------------------------------------------------------
    # * Determine if Keyboard is Active
    #------------------------------------------------------------------------
    def keyboard?
      device == :keyboard
    end
    
    #------------------------------------------------------------------------
    # * Determine if Gamepad is Active
    #------------------------------------------------------------------------
    def gamepad?
      device == :gamepad
    end
    
    #------------------------------------------------------------------------
    # * Determine if No Device Detected
    #------------------------------------------------------------------------
    def none?
      device == :none
    end
    
    #------------------------------------------------------------------------
    # * Reset Device State
    #------------------------------------------------------------------------
    def reset
      @device = :none
    end
    
    #------------------------------------------------------------------------
    # * Frame Update
    #------------------------------------------------------------------------
    def update
      if _gamepad_active?
        @device = :gamepad
      elsif _keyboard_active?
        @device = :keyboard
      end
    end
    
    #------------------------------------------------------------------------
    # * Determine if Controller API is Available
    #------------------------------------------------------------------------
    def _controller_available?
      return @controller_available unless @controller_available.nil?
      @controller_available = (
        Input.const_defined?(:Controller) &&
        Input::Controller.respond_to?(:connected?) &&
        Input::Controller.respond_to?(:pressex?)
      ) rescue false
    end
    
    #------------------------------------------------------------------------
    # * Determine if Keyboard API is Available
    #------------------------------------------------------------------------
    def _keyboard_available?
      return @keyboard_available unless @keyboard_available.nil?
      @keyboard_available = Input.respond_to?(:raw_key_states) rescue false
    end
    
    #------------------------------------------------------------------------
    # * Determine if Any Gamepad Button is Pressed
    #------------------------------------------------------------------------
    def _gamepad_active?
      return false unless _controller_available?
      return false unless Input::Controller.connected? rescue false
      GAMEPAD_BUTTONS.any? { |b| Input::Controller.pressex?(b) rescue false }
    end
    
    #------------------------------------------------------------------------
    # * Determine if Any Keyboard Key is Pressed
    #------------------------------------------------------------------------
    def _keyboard_active?
      return false unless _keyboard_available?
      states = Input.raw_key_states rescue nil
      return false if states.nil?
      states.any?
    end
    
  end # InputDeviceTracker
end # Hammy

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Update Frame (Basic)                                       [Overridden]
  #--------------------------------------------------------------------------
  def update_basic
    Graphics.update
    Input.update
    Hammy::InputDeviceTracker.update
    update_all_windows
  end
  
end # Scene_Base

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
