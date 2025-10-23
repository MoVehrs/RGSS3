#==============================================================================
# ▼ Hammy - FF9 Windowskin System v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 23.10.2025
# -- Requires: None
# -- Recommended: None
# -- Credits: Jet10985 (Windowskin Changer), Yanfly (Documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_ff9_windowskin_system] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 23.10.2025 - Initial release. (v1.00)
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
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Per-window-class type configuration for specialized graphics
# ★ Configurable windowskin filenames for each type and color combination
# ★ Configurable window background opacity
# 
# -----------------------------------------------------------------------------
# ► Technical Features
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
# The following script calls are available for use anywhere in your game.
# These methods allow you to change the windowskin color theme during gameplay.
# 
# -----------------------------------------------------------------------------
# ► Color Theme Management
# -----------------------------------------------------------------------------
# ★ $game_system.windowskin_color = :grey
#   Changes all windows to use the grey color theme.
#   - Returns: nil
# 
# ★ $game_system.windowskin_color = :blue
#   Changes all windows to use the blue color theme.
#   - Returns: nil
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

module CONFIG
  module FF9_WINDOWSKIN
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Windowskin File Names -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the windowskin graphic filenames for different window types and
    # color themes. All windowskin files should be placed in the Graphics/System
    # folder of your project.
    # 
    # GREY_DEFAULT: Default grey windowskin for standard windows
    # BLUE_DEFAULT: Default blue windowskin for standard windows
    # GREY_FRAME: Grey windowskin for frame-type windows
    # BLUE_FRAME: Blue windowskin for frame-type windows
    # GREY_TOPBAR: Grey windowskin for topbar-type windows
    # BLUE_TOPBAR: Blue windowskin for topbar-type windows
    # HELP_SYSTEM: Special windowskin for help windows
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    GREY_DEFAULT = "Window_Default_Grey"
    BLUE_DEFAULT = "Window_Default_Blue"
    GREY_FRAME   = "Window_Frame_Grey"
    BLUE_FRAME   = "Window_Frame_Blue"
    GREY_TOPBAR  = "Window_Topbar_Grey"
    BLUE_TOPBAR  = "Window_Topbar_Blue"
    HELP_SYSTEM  = "Window_Help_System"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Type Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure window classes to use specific windowskin types. This allows
    # different window classes to automatically use specialized windowskin
    # graphics based on their designated type.
    # 
    # WINDOW_TYPES: Hash mapping window classes to their designated types
    #   Available types: :default, :frame, :topbar, :help
    #   Windows not listed here will automatically default to :default type
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOW_TYPES = {
      Window_MenuCommand => :frame,
      Window_MenuStatus => :topbar,
      Window_Gold => :frame,
      Window_TitleCommand => :frame
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Background Opacity -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the default background opacity for all windows in the game.
    # This controls the transparency of the window background content area.
    # 
    # BACK_OPACITY: Background opacity value (0-255, where 255 is fully opaque)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
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
    
  end # CONFIG::FF9_WINDOWSKIN
end # CONFIG

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
  alias_method :ff9_windowskin_game_sys_initialize, :initialize
  
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
  alias_method :ff9_windowskin_win_base_initialize, :initialize
  alias_method :ff9_windowskin_win_base_update, :update
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize(*args)
    ff9_windowskin_win_base_initialize(*args)
    
    self.back_opacity = CONFIG::FF9_WINDOWSKIN::BACK_OPACITY
    @window_type = CONFIG::FF9_WINDOWSKIN.get_window_type(self.class)
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
    skin_name = CONFIG::FF9_WINDOWSKIN.get_windowskin(@window_type, color)
    self.windowskin = Cache.system(skin_name)
    @windowskin_color = color
  end
  
end # Window_Base

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================