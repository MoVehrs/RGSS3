# encoding: utf-8
#==============================================================================
# ▼ Hammy - FF9 Windowskin System v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: None
# -- Recommended: None
# -- Credits: Jet10985 (Windowskin Changer)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_ff9_windowskin_system] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 25.05.2026 - (v1.01) Applied new documentation conventions.
#              Migrated configuration modules to Hammy::PascalCase naming.
#              Added unless $@ guards to alias definitions.
# 
# 23.10.2025 - (v1.00) Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an authentic Final Fantasy IX windowskin system for RPG
# Maker VX Ace. It allows different window types to use specialized windowskin
# graphics based on their class and function.
# 
# The system supports multiple window types (default, frame, topbar, help) and
# allows for easy color switching between grey and blue themes throughout the
# game.
# 
# -----------------------------------------------------------------------------
# ► Core Windowskin Features
# -----------------------------------------------------------------------------
# ★ Automatic windowskin assignment based on window class and type
# ★ Runtime color theme switching via Game_System integration
# ★ Multiple window type support (default, frame, topbar, help)
# ★ Dual color theme system (grey and blue)
# 
# -----------------------------------------------------------------------------
# ► Windowskin Customization Features
# -----------------------------------------------------------------------------
# ★ Per-window-class type configuration for specialized graphics
# ★ Configurable windowskin filenames for each type and color combination
# ★ Configurable window background opacity
# 
# -----------------------------------------------------------------------------
# ► Windowskin Technical Features
# -----------------------------------------------------------------------------
# ★ Real-time windowskin updates when color theme changes
# ★ Automatic window type detection with default fallback
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_System (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → ff9_windowskin_game_sys_initialize
# 
# -----------------------------------------------------------------------------
# ► Window_Base (Class < Window)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → ff9_windowskin_win_base_initialize
#   - update → ff9_windowskin_win_base_update
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events and other scripts.
# 
# -----------------------------------------------------------------------------
# ► Color Theme Management
# -----------------------------------------------------------------------------
# ★ $game_system.windowskin_color = :grey
#   Changes all windows to use the grey color theme.
# 
# ★ $game_system.windowskin_color = :blue
#   Changes all windows to use the blue color theme.
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
# ** FF9 Windowskin System Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the FF9 Windowskin System.
#==============================================================================

module Hammy
  module FF9WindowskinSystem
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Windowskin File Names -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the windowskin graphic filenames for different window types
    # and color themes. All windowskin files should be placed in the
    # Graphics/System folder of your project.
    # 
    # GREY_DEFAULT: Default grey windowskin for standard windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Default_Grey"
    # 
    # BLUE_DEFAULT: Default blue windowskin for standard windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Default_Blue"
    # 
    # GREY_FRAME: Grey windowskin for frame-type windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Frame_Grey"
    # 
    # BLUE_FRAME: Blue windowskin for frame-type windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Frame_Blue"
    # 
    # GREY_TOPBAR: Grey windowskin for topbar-type windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Topbar_Grey"
    # 
    # BLUE_TOPBAR: Blue windowskin for topbar-type windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Topbar_Blue"
    # 
    # HELP_SYSTEM: Special windowskin for help windows.
    #   - Valid values: String containing filename without extension
    #   - Default: "Window_Help_System"
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    GREY_DEFAULT = "Window_Default_Grey"
    BLUE_DEFAULT = "Window_Default_Blue"
    GREY_FRAME   = "Window_Frame_Grey"
    BLUE_FRAME   = "Window_Frame_Blue"
    GREY_TOPBAR  = "Window_Topbar_Grey"
    BLUE_TOPBAR  = "Window_Topbar_Blue"
    HELP_SYSTEM  = "Window_Help_System"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Type Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure window classes to use specific windowskin types. This allows
    # different window classes to automatically use specialized windowskin
    # graphics based on their designated type.
    # 
    # WINDOW_TYPES: Hash mapping window classes to their designated types.
    #   Available types: :default, :frame, :topbar, :help
    #   Windows not listed here will automatically default to :default type.
    #   - Valid values: Hash with Window Class keys and Symbol values
    #   - Default: { Window_MenuCommand => :frame, ... }
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOW_TYPES = {
      Window_MenuCommand => :frame,
      Window_MenuStatus => :topbar,
      Window_Gold => :frame,
      Window_TitleCommand => :frame
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Background Opacity -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the default background opacity for all windows in the game.
    # This controls the transparency of the window background content area.
    # 
    # BACK_OPACITY: Background opacity value (0-255, 255 is fully opaque).
    #   - Valid values: Integer from 0 to 255
    #   - Default: 255
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BACK_OPACITY = 255
    
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
    # * Get Windowskin File Name                                     [Custom]
    #------------------------------------------------------------------------
    def self.get_windowskin(window_type, color)
      case window_type
      when :frame
        color == :blue ? BLUE_FRAME : GREY_FRAME
      when :topbar
        color == :blue ? BLUE_TOPBAR : GREY_TOPBAR
      when :help
        HELP_SYSTEM
      else
        color == :blue ? BLUE_DEFAULT : GREY_DEFAULT
      end
    end
    
    #------------------------------------------------------------------------
    # * Get Window Type                                              [Custom]
    #------------------------------------------------------------------------
    def self.get_window_type(window_class)
      WINDOW_TYPES[window_class] || :default
    end
    
  end # Hammy::FF9WindowskinSystem
end # Hammy

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_accessor :windowskin_color
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_windowskin_game_sys_initialize, :initialize unless $@
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    ff9_windowskin_game_sys_initialize
    @windowskin_color = :grey
  end
  
end # Game_System

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_windowskin_win_base_initialize, :initialize unless $@
  alias_method :ff9_windowskin_win_base_update, :update unless $@
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize(*args)
    ff9_windowskin_win_base_initialize(*args)
    
    self.back_opacity = Hammy::FF9WindowskinSystem::BACK_OPACITY
    @window_type = Hammy::FF9WindowskinSystem.get_window_type(self.class)
    @windowskin_color = :grey
    
    update_windowskin
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_windowskin_win_base_update
    
    current_color = get_current_color
    if @windowskin_color != current_color
      update_windowskin
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Current Color Theme                                        [Custom]
  #--------------------------------------------------------------------------
  def get_current_color
    $game_system.windowskin_color || :grey
  end
  
  #--------------------------------------------------------------------------
  # * Update Windowskin Based on Type and Color                      [Custom]
  #--------------------------------------------------------------------------
  def update_windowskin
    color = get_current_color
    skin_name = Hammy::FF9WindowskinSystem.get_windowskin(@window_type, color)
    self.windowskin = Cache.system(skin_name)
    @windowskin_color = color
  end
  
end # Window_Base

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
