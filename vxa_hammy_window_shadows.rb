#==============================================================================
# ▼ Hammy - Window Shadows v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 23.10.2025
# -- Requires: None
# -- Recommended: None
# -- Credits: Yanfly (Documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_window_shadows] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 23.10.2025 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a customizable shadow system for all windows in RPG
# Maker VX Ace. It automatically adds shadows behind windows to create depth
# and visual polish in your game's user interface.
# 
# The system supports per-window customization, integration with the Hammy FF9
# Windowskin System for type-based shadow configuration, and complete control
# over shadow appearance including offset and opacity.
# 
# -----------------------------------------------------------------------------
# ► Core Shadow Features
# -----------------------------------------------------------------------------
# ★ Automatic shadow creation for all windows
# ★ Runtime shadow enable/disable via Game_System integration
# ★ Window exclusion system for selective shadow application
# ★ Explicit z-index management for proper shadow layering
# 
# -----------------------------------------------------------------------------
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Per-window-class shadow configuration with custom graphics and settings
# ★ Per-window-type shadow configuration via Windowskin System integration
# ★ Configurable shadow offset (horizontal and vertical positioning)
# ★ Shadow opacity scaling based on parent window transparency
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Automatic shadow property updates (position, size, openness and visibility)
# ★ Dynamic shadow recreation when system is re-enabled
# ★ Proper shadow disposal and cleanup on window termination
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_System (Class)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - window_shadows (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → window_shadows_game_sys_initialize
# 
# -----------------------------------------------------------------------------
# ► Window_Base (Class < Window)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → window_shadows_win_base_initialize
#   - dispose → window_shadows_win_base_dispose
#   - update → window_shadows_win_base_update
# 
# ★ Super Methods:
#   - x=
#   - y=
#   - z=
#   - width=
#   - height=
#   - openness=
#   - visible=
#   - opacity=
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains how to prepare windowskin graphics for use as shadows.
# 
# -----------------------------------------------------------------------------
# ► Shadow Windowskin Preparation
# -----------------------------------------------------------------------------
# Shadow windowskins are modified versions of standard RPG Maker VX Ace
# windowskin files. Windowskins are 128x128 pixels in size.
# 
# ★ To create a shadow windowskin from a standard windowskin:
# 
# 1. Start with your standard windowskin file (128x128 pixels)
# 
# 2. Keep only the upper-right quadrant (x: 64-128, y: 0-64)
#    - This section contains the window border graphics
#    - Everything else should be removed or made transparent
# 
# 3. Remove the top and left border segments
#    - Delete the upper portion of the window frame
#    - Delete the left portion of the window frame
#    - Delete the scroll arrows
#    - Keep only the bottom and right border segments
# 
# 4. The result should show only the lower-right corner and edges
#    - This creates the shadow effect when offset behind the main window
# 
# 5. Place your prepared shadow windowskin files in the Graphics/System folder
#    and reference them in the configuration settings.
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use anywhere in your game.
# These methods allow you to control the shadow system during gameplay.
# 
# -----------------------------------------------------------------------------
# ► Shadow System Control
# -----------------------------------------------------------------------------
# ★ $game_system.window_shadows = true
#   Enables the window shadow system globally.
#   - All windows will display their configured shadows.
#   - Returns: nil
# 
# ★ $game_system.window_shadows = false
#   Disables the window shadow system globally.
#   - All window shadows will be hidden and disposed.
#   - Returns: nil
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ If using Hammy FF9 Windowskin System, place this script BELOW the
#   Windowskin System script.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** Window Shadows Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Window Shadows system.
#==============================================================================

module CONFIG
  module WINDOW_SHADOWS
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Default Shadow Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the default shadow appearance for all windows in the game.
    # These settings control the shadow windowskin graphic, positioning offset,
    # and transparency. Set windowskin to nil to disable shadows globally.
    # 
    # DEFAULT_SETTINGS: Hash containing default shadow configuration
    #   :windowskin - Shadow windowskin filename in Graphics/System folder
    #   :offset_x - Horizontal shadow offset in pixels (positive = right)
    #   :offset_y - Vertical shadow offset in pixels (positive = down)
    #   :opacity - Shadow opacity value (0-255, where 255 is fully opaque)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    DEFAULT_SETTINGS = {
      :windowskin => "Window_Shadow",
      :offset_x => 3,
      :offset_y => 3,
      :offset_width => 0,
      :offset_height => 0,
      :opacity => 120
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Excluded Windows -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure window classes that should not display shadows. Add window
    # class constants to exclude specific windows from the shadow
    # system entirely.
    # 
    # EXCLUDED_WINDOWS: Array of window class constants to exclude
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    EXCLUDED_WINDOWS = [Window_BattleLog]
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Explicit Z-Index Windows -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure window classes that require explicit z-index assignment during
    # initialization. Windows without explicit z-values may cause their shadows
    # to appear above other parent windows when shadows are re-enabled.
    # 
    # EXPLICIT_Z_WINDOWS: Array of window class constants requiring
    #                     explicit z-index assignment (z = 200)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    EXPLICIT_Z_WINDOWS = [Window_ChoiceList]
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Class Shadow Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure custom shadow settings for specific window classes. This allows
    # you to override the default shadow appearance for individual window types
    # with per-class customization of shadow graphics and positioning.
    # 
    # WINDOWSKIN_MAP: Hash mapping window class names to custom shadow settings
    #   Format: "ClassName" => { 
    #     :windowskin => "Name", 
    #     :offset_x => x, 
    #     :offset_y => y, 
    #     :opacity => o
    #   }
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOWSKIN_MAP = {
       "Window_MenuCommand" => {
         :windowskin => "Window_Shadow_Red",
         :offset_x => 3,
         :offset_y => 3,
         :offset_width => 0,
         :offset_height => 0,
         :opacity => 80
       },
      "Window_Gold" => {
        :windowskin => "Window_Shadow",
        :offset_x => 0,
        :offset_y => 0,
        :offset_width => 3,
        :offset_height => 3,
        :opacity => 80
      },
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Type Shadow Map -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure custom shadow settings for window types when using the Hammy 
    # FF9 Windowskin System. This allows shadows to automatically match the
    # visual style of different window types defined in the Windowskin System.
    # 
    # WINDOW_TYPE_MAP: Hash mapping window types to custom shadow settings
    #   Format: :window_type => { 
    #     :windowskin => "Name", 
    #     :offset_x => x, 
    #     :offset_y => y,
    #     :opacity => o
    #   }
    #   Available types: :default, :frame, :topbar, :help
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOW_TYPE_MAP = {
      :default => {
        :windowskin => "Window_Shadow_Default",
        :offset_x => 2,
        :offset_y => 2,
        :offset_width => 0,
        :offset_height => 0,
        :opacity => 120
      },
      :frame => {
        :windowskin => "Window_Shadow_Frame",
        :offset_x => 2,
        :offset_y => 2,
        :offset_width => 0,
        :offset_height => 0,
        :opacity => 120
      },
      :topbar => {
        :windowskin => "Window_Shadow_Topbar",
        :offset_x => 2,
        :offset_y => 2,
        :offset_width => 0,
        :offset_height => 0,
        :opacity => 120
      },
      :help => {
        :windowskin => "Window_Shadow_Default",
        :offset_x => 2,
        :offset_y => 2,
        :offset_width => 0,
        :offset_height => 0,
        :opacity => 120
      },
    }
    
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
    # * Get Shadow Settings                                          [Custom]
    #------------------------------------------------------------------------
    def self.get_shadow_settings(window_class, window_type = nil)
      if $imported[:hammy_ff9_windowskin_system] && window_type
        type_settings = WINDOW_TYPE_MAP[window_type]
        if type_settings
          return type_settings
        end
      end
      
      class_settings = WINDOWSKIN_MAP[window_class.name]
      if class_settings
        return DEFAULT_SETTINGS.merge(class_settings)
      else
        return DEFAULT_SETTINGS
      end
    end
    
    #------------------------------------------------------------------------
    # * Explicit Z-Index Window Initialization                       [Custom]
    #------------------------------------------------------------------------
    EXPLICIT_Z_WINDOWS.each do |window_class|
      next unless window_class.is_a?(Class)
      
      class_name = window_class.name.downcase
      alias_name = "window_shadows_#{class_name}_initialize".to_sym
      
      window_class.class_eval do
        alias_method alias_name, :initialize
        
        define_method(:initialize) do |*args, &block|
          send(alias_name, *args, &block)
          self.z = 200
        end
      end
    end
    
  end # CONFIG::WINDOW_SHADOWS
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
  attr_accessor :window_shadows
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :window_shadows_game_sys_initialize, :initialize
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    window_shadows_game_sys_initialize
    @window_shadows = true
  end
  
end # Game_System

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :window_shadows_win_base_initialize, :initialize
  alias_method :window_shadows_win_base_dispose, :dispose
  alias_method :window_shadows_win_base_update, :update
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    window_shadows_win_base_initialize(x, y, width, height)
    create_shadow_window
  end
  
  #--------------------------------------------------------------------------
  # * Free                                                            [Alias]
  #--------------------------------------------------------------------------
  def dispose
    if shadow_window_active?
      @shadow_window.visible = false
      @shadow_window.dispose
      @shadow_window = nil
    end
    
    window_shadows_win_base_dispose
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    window_shadows_win_base_update
    
    shadows_enabled = $game_system.window_shadows
    
    if shadow_window_active?
      if @shadow_window.shadow_enabled && !shadows_enabled
        @shadow_window.shadow_enabled = false
        @shadow_window.dispose
        @shadow_window = nil
      end
    end
    
    if (!@shadow_window || @shadow_window.disposed?) && shadows_enabled
      create_shadow_window
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set X Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def x=(value)
    super
    if shadow_window_active?
      @shadow_window.x = value + @shadow_window.offset_x
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Y Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def y=(value)
    super
    if shadow_window_active?
      @shadow_window.y = value + @shadow_window.offset_y
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Z Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def z=(value)
    super
    if shadow_window_active?
      @shadow_window.z = value - 1
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Width                                                       [Super]
  #--------------------------------------------------------------------------
  def width=(value)
    super
    if shadow_window_active?
      @shadow_window.width = value + @shadow_window.offset_width
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Height                                                      [Super]
  #--------------------------------------------------------------------------
  def height=(value)
    super
    if shadow_window_active?
      @shadow_window.height = value + @shadow_window.offset_height
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Openness                                                    [Super]
  #--------------------------------------------------------------------------
  def openness=(value)
    super
    if shadow_window_active?
      @shadow_window.openness = value
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Visibility                                                  [Super]
  #--------------------------------------------------------------------------
  def visible=(value)
    super
    if shadow_window_active?
      @shadow_window.visible = value
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Opacity                                                     [Super]
  #--------------------------------------------------------------------------
  def opacity=(value)
    super
    if shadow_window_active?
      ratio = value / 255.0
      @shadow_window.opacity = (@shadow_window.shadow_opacity * ratio).to_i
    end
  end
  
  #--------------------------------------------------------------------------
  # * Check Shadow Window Active                                     [Custom]
  #--------------------------------------------------------------------------
  def shadow_window_active?
    @shadow_window && !@shadow_window.disposed?
  end
  
  #--------------------------------------------------------------------------
  # * Create Shadow Window                                           [Custom]
  #--------------------------------------------------------------------------
  def create_shadow_window
    return if @is_shadow
    return if CONFIG::WINDOW_SHADOWS::EXCLUDED_WINDOWS.include?(self.class)
    
    window_type = nil
    if $imported && $imported[:hammy_ff9_windowskin_system]
      window_type = CONFIG::FF9_WINDOWSKIN.get_window_type(self.class)
    end
    
    settings = CONFIG::WINDOW_SHADOWS.get_shadow_settings(self.class, window_type)
    return unless settings[:windowskin]
    
    @shadow_window = Window_Shadow.new(settings)
    @shadow_window.setup(self)
  end
  
end # Window_Base

#==============================================================================
# ** Window_Shadow
#------------------------------------------------------------------------------
#  This window displays shadows behind parent windows for visual depth.
#==============================================================================

class Window_Shadow < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_reader :offset_x
  attr_reader :offset_y
  attr_reader :offset_width
  attr_reader :offset_height
  attr_reader :shadow_opacity
  attr_accessor :shadow_enabled
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Super]
  #--------------------------------------------------------------------------
  def initialize(settings)
    @is_shadow = true
    super(0, 0, 0, 0)
    @shadow_enabled = false
    
    @offset_x = settings[:offset_x]
    @offset_y = settings[:offset_y]
    @offset_width = settings[:offset_width]
    @offset_height = settings[:offset_height]
    @shadow_opacity = settings[:opacity]
    
    if settings[:windowskin]
      self.windowskin = Cache.system(settings[:windowskin])
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Tone                                                 [Overwrite]
  #--------------------------------------------------------------------------
  def update_tone
  end
  
  #--------------------------------------------------------------------------
  # * Setup                                                          [Custom]
  #--------------------------------------------------------------------------
  def setup(parent_window)
    self.x = parent_window.x + @offset_x
    self.y = parent_window.y + @offset_y
    self.z = parent_window.z - 1
    self.width = parent_window.width + @offset_width
    self.height = parent_window.height + @offset_height
    self.openness = parent_window.openness
    self.visible = parent_window.visible && $game_system.window_shadows
    
    ratio = parent_window.opacity / 255.0
    self.opacity = (@shadow_opacity * ratio).to_i
    
    @shadow_enabled = true
  end
  
end # Window_Shadow

#==============================================================================
# 
# ▼ End of File
#
#==============================================================================