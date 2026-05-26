# encoding: utf-8
#==============================================================================
# ▼ Hammy - Simple Map Display × Input Toggle v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: Simple Map Display v2.4 by WoodPenguin
# -- Optional: Hammy - MKXP-Z Input Constants v1.01+
# -- Recommended: None
# -- Credits: WoodPenguin (Simple Map Display system)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_simple_map_display_input_toggle] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 25.05.2026 - (v1.01) Applied new documentation conventions.
# 
# 17.05.2026 - (v1.00) Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This input addon enhances WoodPenguin's Simple Map Display script with
# direct player input handling for RPG Maker VX Ace. It allows the player to
# cycle through a configurable sequence of map display modes via keyboard or
# controller without requiring an event or variable change through the event
# system.
# 
# The system supports a configurable cycle order and mode selection, keyboard
# input via Input.trigger? on vanilla VX Ace and Input.triggerex? on mkxp-z,
# raw SDL scancode and Windows Virtual-Key support for unmapped keys, and an
# optional controller button mapping via Input::Controller.triggerex?.
# 
# -----------------------------------------------------------------------------
# ► Input Toggle Features
# -----------------------------------------------------------------------------
# ★ Configurable map display cycle order via module setting
# ★ Keyboard toggle support through RGSS3 and mkxp-z input routing
# ★ Explicit RGSS and SDL routing via tagged key arrays
# ★ Optional Windows Virtual-Key integer support on mkxp-z
# ★ Optional controller button toggle support on mkxp-z
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► Spriteset_SimpleMap (Class < Spriteset_Base)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ This script requires WoodPenguin - Simple Map Display and must be placed
#   BELOW it.
# 
# ★ If using Hammy - MKXP-Z Input Constants, place this script BELOW it.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** Simple Map Display × Input Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Simple Map Display × Input system.
#==============================================================================

module Hammy
  module SimpleMapInput
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Cycle Order -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Set the sequence of display modes the toggle cycles through.
    # 
    # TOGGLE_CYCLE: Array of mode values to cycle through in order.
    #   Include 0 to pass through the hidden state as part of the cycle.
    #   Remove 0 to keep the map visible and only cycle between modes.
    #   Set to [] to disable the toggle entirely.
    #   - Valid values: Array of integers corresponding to WdTk::SimpMap keys
    #   - Default: [0, 1, 2, 3]
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TOGGLE_CYCLE = [0, 1, 2, 3]
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Keyboard Toggle Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the keyboard key used to cycle the map display mode.
    # 
    # TOGGLE_KEY: Keyboard key used as the map display toggle trigger.
    #   Bare RGSS3 symbols are routed through Input.trigger?. Tagged arrays
    #   can force routing with [:rgss, :SYM] or [:sdl, :SYM]. SDL routing
    #   and bare VK integers are mkxp-z only and use Input.triggerex?.
    #   - Valid values: RGSS symbol, tagged array, or VK integer
    #   - Default: :CTRL
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TOGGLE_KEY = :CTRL
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Controller Button Settings (mkxp-z only) -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the controller button used to cycle the map display mode
    # on mkxp-z.
    # 
    # TOGGLE_BUTTON: Controller button used as map display toggle trigger.
    #   Only needed when TOGGLE_KEY has no default controller binding,
    #   such as an SDL-only key or a raw VK integer. Set to nil to disable
    #   the separate controller trigger.
    #   - Valid values: Any controller button symbol, or nil
    #   - Default: :BACK
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TOGGLE_BUTTON = :BACK
    
  end # SimpleMapInput
end # Hammy

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
# ** Spriteset_SimpleMap
#------------------------------------------------------------------------------
#  This spriteset handles the simple map overlay display. It is created and
# managed within the Spriteset_Map class.
#==============================================================================

class Spriteset_SimpleMap
  #--------------------------------------------------------------------------
  # * Class Variables                                                [Custom]
  #--------------------------------------------------------------------------
  @@mkxpz = (RUBY_VERSION >= "3.1")
  
  #--------------------------------------------------------------------------
  # * Frame Update                                               [Overridden]
  #--------------------------------------------------------------------------
  def update
    update_input
    
    if @map_id != $game_map.map_id ||
       @index != $game_variables[WdTk::SimpMap::VariableID]
      create_map_bitmap if @map_id != $game_map.map_id
      
      @map_id = $game_map.map_id
      @index = $game_variables[WdTk::SimpMap::VariableID]
      
      setup
    end
    
    if @params
      case @params[:type]
      when 1 then update_all_marker(true)
      when 2 then update_all_marker(false)
      when 3 then update_type3
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Input                                                   [Custom]
  #--------------------------------------------------------------------------
  def update_input
    return unless keyboard_triggered? || controller_triggered?
    return if Hammy::SimpleMapInput::TOGGLE_CYCLE.empty?
    
    var = $game_variables[WdTk::SimpMap::VariableID]
    idx = Hammy::SimpleMapInput::TOGGLE_CYCLE.index(var) || -1
    
    $game_variables[WdTk::SimpMap::VariableID] =
      Hammy::SimpleMapInput::TOGGLE_CYCLE[(idx + 1) %
      Hammy::SimpleMapInput::TOGGLE_CYCLE.size]
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Keyboard Key is Triggered                         [Custom]
  #--------------------------------------------------------------------------
  def keyboard_triggered?
    key = Hammy::SimpleMapInput::TOGGLE_KEY
    if key.is_a?(Integer)
      Input.triggerex?(key)
    elsif key.is_a?(Array)
      tag, val = key
      tag == :rgss ? Input.trigger?(val) : Input.triggerex?(val)
    else
      Input.trigger?(key)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Controller Button is Triggered                    [Custom]
  #--------------------------------------------------------------------------
  def controller_triggered?
    return false unless @@mkxpz
    return false if Hammy::SimpleMapInput::TOGGLE_BUTTON.nil?
    return false unless Input::Controller.connected?
    
    Input::Controller.triggerex?(Hammy::SimpleMapInput::TOGGLE_BUTTON)
  end
  
end # Spriteset_SimpleMap

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
