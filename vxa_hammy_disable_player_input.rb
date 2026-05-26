# encoding: utf-8
#==============================================================================
# ▼ Hammy - Disable Player Input v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: None
# -- Recommended: None
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_disable_player_input] = true

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
# This script provides a simple toggle for disabling player movement input in
# RPG Maker VX Ace. It allows developers to lock player controls during
# specific game events, cutscenes, or gameplay sequences.
# 
# The system supports switch-based activation, configurable switch ID
# selection, and automatic input blocking without affecting other game systems.
# 
# -----------------------------------------------------------------------------
# ► Core Movement Input Features
# -----------------------------------------------------------------------------
# ★ Complete player movement input blocking
# ★ Switch-based input blocking via configurable setting
# ★ Alias method pattern for safe compatibility
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_Player (Class < Game_Character)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - move_by_input → disable_input_gp_move_by_input
#   - check_action_event → disable_input_gp_chk_act_evnt
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events and other scripts.
# 
# -----------------------------------------------------------------------------
# ► Input Control
# -----------------------------------------------------------------------------
# ★ $game_switches[Hammy::DisablePlayerInput::MOVEMENT_SWITCH_ID] = true/false
#   Directly set the movement input switch state using the game switches array.
#   - true: Disables player movement input
#   - false: Enables player movement input
# 
# ★ $game_switches[Hammy::DisablePlayerInput::ACTION_SWITCH_ID] = true/false
#   Directly set the interaction switch state using the game switches array.
#   - true: Disables event interaction with :C input
#   - false: Enables event interaction with :C input
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains how to configure and use the movement input disable
# feature.
# 
# -----------------------------------------------------------------------------
# ► Configuration
# -----------------------------------------------------------------------------
# Edit the switch constants in the Hammy::DisablePlayerInput module to
# set which game switches control the input locks.
# 
# ★ MOVEMENT_SWITCH_ID: Game switch ID for movement input blocking
#   - Set to any valid switch ID (1 to maximum switches in your project)
#   - When this switch is ON, player movement input is blocked
#   - When this switch is OFF, player movement input works normally
#   - Default: 10
# 
# ★ ACTION_SWITCH_ID: Game switch ID for event interaction blocking
#   - Set to any valid switch ID (1 to maximum switches in your project)
#   - When this switch is ON, event interaction with :C input is blocked
#   - When this switch is OFF, event interaction with :C input works normally
#   - Default: 11
# 
# ★ Examples:
#   - MOVEMENT_SWITCH_ID = 10
#     Uses switch #10 to control movement input blocking
# 
#   - ACTION_SWITCH_ID = 11
#     Uses switch #11 to control event interaction blocking
# 
# -----------------------------------------------------------------------------
# ► Usage
# -----------------------------------------------------------------------------
# Use event commands or script calls to toggle the specified switches.
# 
# ★ Event Command Method:
#   - Control Switches: Turn ON switch [MOVEMENT_SWITCH_ID]
#     Disables player movement input
# 
#   - Control Switches: Turn OFF switch [MOVEMENT_SWITCH_ID]
#     Re-enables player movement input
# 
#   - Control Switches: Turn ON switch [ACTION_SWITCH_ID]
#     Disables event interaction with :C input
# 
#   - Control Switches: Turn OFF switch [ACTION_SWITCH_ID]
#     Re-enables event interaction with :C input
# 
# ★ Script Call Method:
#   - Enable movement input blocking:
#     $game_switches[Hammy::DisablePlayerInput::MOVEMENT_SWITCH_ID] = true
# 
#   - Disable movement input blocking:
#     $game_switches[Hammy::DisablePlayerInput::MOVEMENT_SWITCH_ID] = false
# 
#   - Enable event interaction blocking:
#     $game_switches[Hammy::DisablePlayerInput::ACTION_SWITCH_ID] = true
# 
#   - Disable event interaction blocking:
#     $game_switches[Hammy::DisablePlayerInput::ACTION_SWITCH_ID] = false
# 
# -----------------------------------------------------------------------------
# ► Important Notes
# -----------------------------------------------------------------------------
# This script provides independent control over movement input and event
# interaction. Each feature is controlled by a separate switch.
# 
# ★ Menu access is not affected by this script. If you want to block menu
#   access as well, use the "Disable Menu Access" event command.
# 
# ★ Both switches can be set to the same ID to control movement and
#   interaction simultaneously with a single switch if desired.
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
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** Disable Player Input Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Disable Player Input system.
#==============================================================================

module Hammy
  module DisablePlayerInput
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Switch Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the game switches used to control player input blocking.
    # 
    # MOVEMENT_SWITCH_ID: Controls player movement input blocking.
    #   When this switch is ON, player movement input is disabled.
    #   When OFF, movement input works normally.
    #   - Valid values: Any valid switch ID (1 to max switches in project)
    #   - Default: 10
    # 
    # ACTION_SWITCH_ID: Controls event interaction with :C input blocking.
    #   When this switch is ON, event interaction with :C input is disabled.
    #   When OFF, event interaction works normally.
    #   - Valid values: Any valid switch ID (1 to max switches in project)
    #   - Default: 11
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    MOVEMENT_SWITCH_ID = 10
    ACTION_SWITCH_ID = 11
    
  end # DisablePlayerInput
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
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :disable_input_gp_move_by_input, :move_by_input unless $@
  alias_method :disable_input_gp_chk_act_evnt, :check_action_event unless $@
  
  #--------------------------------------------------------------------------
  # * Move by Input                                                   [Alias]
  #--------------------------------------------------------------------------
  def move_by_input
    return if $game_switches[Hammy::DisablePlayerInput::MOVEMENT_SWITCH_ID]
    disable_input_gp_move_by_input
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Event Start Caused by [OK] Button                  [Alias]
  #--------------------------------------------------------------------------
  def check_action_event
    return false if $game_switches[Hammy::DisablePlayerInput::ACTION_SWITCH_ID]
    disable_input_gp_chk_act_evnt
  end
  
end # Game_Player

#==============================================================================
# 
# ▼ End of File
#
#==============================================================================
