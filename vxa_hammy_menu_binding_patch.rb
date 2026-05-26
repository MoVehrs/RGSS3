# encoding: utf-8
#==============================================================================
# ▼ Hammy - Menu Binding Patch v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: None
# -- Recommended: None
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_menu_binding_patch] = true

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
# This script provides a customizable menu trigger system that rebinds the
# main menu away from the default :B button onto alternative inputs.
# 
# The system supports configurable input button selection via module constant,
# clean override of the default Scene_Map menu trigger logic, and seamless
# integration with existing game systems without affecting other input handling.
# 
# -----------------------------------------------------------------------------
# ► Core Menu Binding Features
# -----------------------------------------------------------------------------
# ★ Configurable menu trigger button via module setting
# ★ Clean override of Scene_Map menu trigger logic
# ★ Seamless integration with existing game systems
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Scene_Map (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update_call_menu
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
# ** Menu Binding Patch Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Menu Binding Patch.
#==============================================================================

module Hammy
  module MenuBinding
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Menu Trigger Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the input button used to trigger the main menu. The player
    # must press this button while on the map to open the menu.
    # 
    # MENU_KEY: Keyboard key used to trigger the menu.
    #   - Valid values: Any RGSS3 input symbol (e.g. :X, :CTRL, :SHIFT)
    #   - Default: :X
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    MENU_KEY = :X
    
  end # MenuBinding
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
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button           [Overridden]
  #--------------------------------------------------------------------------
  def update_call_menu
    if $game_system.menu_disabled || $game_map.interpreter.running?
      @menu_calling = false
    else
      @menu_calling ||= Input.trigger?(Hammy::MenuBinding::MENU_KEY)
      call_menu if @menu_calling && !$game_player.moving?
    end
  end
  
end # Scene_Map

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
