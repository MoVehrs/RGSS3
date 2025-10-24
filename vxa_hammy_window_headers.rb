#==============================================================================
# ▼ Hammy - Window Headers v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 24.10.2025
# -- Requires: None
# -- Recommended: Text Cache v1.04 by Mithran
# -- Credits: Yanfly (Documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_window_headers] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 24.10.2025 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a customizable header system for all windows in RPG
# Maker VX Ace. It automatically adds headers above windows to display titles,
# labels, or decorative graphics that enhance your game's user interface.
# 
# The system supports both text-based and image-based headers with complete
# control over positioning, font styling, and per-window customization for
# creating a polished and professional interface design.
# 
# -----------------------------------------------------------------------------
# ► Core Header Features
# -----------------------------------------------------------------------------
# ★ Automatic header creation for configured windows
# ★ Text and image header support with dual content types
# ★ Per-window-class header configuration with custom settings
# 
# -----------------------------------------------------------------------------
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Configurable text styling (font, size, color, outline, shadow)
# ★ Configurable header positioning (horizontal and vertical offsets)
# ★ Support for custom header graphics from Graphics/System/Headers folder
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Automatic header property updates (position, visibility, and z-index)
# ★ Guard mechanism to prevent multiple header creation in inherited classes
# ★ Viewport compatibility for all scene types and window configurations
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Window_Base (Class < Window)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → window_headers_win_base_initialize
#   - dispose → window_headers_win_base_dispose
#   - update → window_headers_win_base_update
#   - x= → window_headers_win_base_x=
#   - y= → window_headers_win_base_y=
#   - z= → window_headers_win_base_z=
#   - visible= → window_headers_win_base_visible=
#   - openness= → window_headers_win_base_openness=
#   - viewport= → window_headers_win_base_viewport=
# 
#==============================================================================
# ▼ Recommended Scripts
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following scripts are highly recommended for optimal performance:
# 
# -----------------------------------------------------------------------------
# ► Text Cache v1.04 by Mithran
# -----------------------------------------------------------------------------
# Prevents text width calculation issues and improves rendering performance
# 
# ★ Benefits for Window Headers:
#   - Accurate text width calculations for dynamic header sizing
#   - Consistent text positioning across different window types
#   - Prevents text drawing issues and character spacing problems
# 
# ★ Installation: Paste Text Cache v1.04 below ▼ Materials/素材 but above
#   all other third party scripts.
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
# ** Window Headers Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Window Headers system.
#==============================================================================

module CONFIG
  module WINDOW_HEADERS
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Header Positioning Offsets -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the positioning offset for header sprites relative to their
    # parent window. These values control where headers appear in relation to
    # the window borders.
    # 
    # TEXT_OFFSET_X: Horizontal offset for text headers (positive = right)
    # TEXT_OFFSET_Y: Vertical offset for text headers (positive = down)
    # IMAGE_OFFSET_X: Horizontal offset for image headers (positive = right)
    # IMAGE_OFFSET_Y: Vertical offset for image headers (positive = down)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TEXT_OFFSET_X = 10
    TEXT_OFFSET_Y = -4
    IMAGE_OFFSET_X = 10
    IMAGE_OFFSET_Y = -2
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Text Header Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the appearance of text-based headers including font properties
    # and color settings. Colors are stored as RGB arrays and converted to
    # Color objects at runtime for better memory efficiency.
    # 
    # TEXT_SETTINGS: Hash containing text header configuration
    #   :font_name - Font family name for header text
    #   :font_size - Font size in pixels for header text
    #   :font_bold - Boolean flag for bold text styling
    #   :font_italic - Boolean flag for italic text styling
    #   :font_outline - Boolean flag for text outline effect
    #   :font_shadow - Boolean flag for text shadow effect
    #   :color - RGB array for main text color [R, G, B] (0-255)
    #   :outline_color - RGB array for text outline color [R, G, B] (0-255)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TEXT_SETTINGS = {
      :font_name => "Arial",
      :font_size => 13,
      :font_bold => false,
      :font_italic => false,
      :font_outline => true,
      :font_shadow => false,
      :color => [255, 255, 255],
      :outline_color => [0, 0, 0]
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Header Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure header settings for specific window classes. Each window class
    # can be assigned either a text header or an image header with custom
    # display content.
    # 
    # HEADERS: Hash mapping window classes to their header configuration
    #   Window class => {:type => :type, :string => "content"}
    #   
    #   :type options:
    #     :text - Display text-based header using TEXT_SETTINGS configuration
    #     :image - Display image-based header from Graphics/System/Headers
    #   
    #   :string content:
    #     For :text type - The text string to display in the header
    #     For :image type - Filename (without extension)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    HEADERS = {
      Window_Gold => {:type => :text, :string => "Gold"},
      Window_MenuCommand => {:type => :text, :string => "Main Menu"},
      Window_MenuStatus => {:type => :text, :string => "Party"},
      Window_SkillList => {:type => :text, :string => "Skills"},
      Window_ChoiceList => {:type => :image, :string => "ChoiceList"}
    }
    
  end # CONFIG::WINDOW_HEADERS
end # CONFIG

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
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# To speed up load times and conserve memory, this module holds the
# created bitmap object in the internal hash, allowing the program to
# return preexisting objects when the same bitmap is requested again.
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * Get Header Graphic
  #--------------------------------------------------------------------------
  def self.header(filename)
    load_bitmap("Graphics/System/Headers/", filename)
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :window_headers_win_base_initialize, :initialize
  alias_method :window_headers_win_base_dispose, :dispose
  alias_method :window_headers_win_base_update, :update
  alias_method :window_headers_win_base_x=, :x=
  alias_method :window_headers_win_base_y=, :y=
  alias_method :window_headers_win_base_z=, :z=
  alias_method :window_headers_win_base_visible=, :visible=
  alias_method :window_headers_win_base_openness=, :openness=
  alias_method :window_headers_win_base_viewport=, :viewport=
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    @header_sprite = nil
    @header_created = false
    window_headers_win_base_initialize(x, y, width, height)
    create_header_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Free                                                            [Alias]
  #--------------------------------------------------------------------------
  def dispose
    dispose_header_sprite
    window_headers_win_base_dispose
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    window_headers_win_base_update
    update_header_sprite if header_sprite_active?
  end
  
  #--------------------------------------------------------------------------
  # * Update Header Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def update_header_sprite
    update_header_position
    update_header_visibility
  end
  
  #--------------------------------------------------------------------------
  # * Update Header Position                                         [Custom]
  #--------------------------------------------------------------------------
  def update_header_position
    if @header_type == :text
      @header_sprite.x = self.x + CONFIG::WINDOW_HEADERS::TEXT_OFFSET_X
      @header_sprite.y = self.y + CONFIG::WINDOW_HEADERS::TEXT_OFFSET_Y
    else
      @header_sprite.x = self.x + CONFIG::WINDOW_HEADERS::IMAGE_OFFSET_X
      @header_sprite.y = self.y + CONFIG::WINDOW_HEADERS::IMAGE_OFFSET_Y
    end
    
    @header_sprite.z = self.z + 1
  end
  
  #--------------------------------------------------------------------------
  # * Update Header Visibility                                       [Custom]
  #--------------------------------------------------------------------------
  def update_header_visibility
    @header_sprite.visible = self.visible && self.openness == 255
  end
  
  #--------------------------------------------------------------------------
  # * Set X Coordinate                                                [Alias]
  #--------------------------------------------------------------------------
  def x=(value)
    self.window_headers_win_base_x = value
    
    if header_sprite_active?
      if @header_type == :text
        @header_sprite.x = value + CONFIG::WINDOW_HEADERS::TEXT_OFFSET_X
      else
        @header_sprite.x = value + CONFIG::WINDOW_HEADERS::IMAGE_OFFSET_X
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Y Coordinate                                                [Alias]
  #--------------------------------------------------------------------------
  def y=(value)
    self.window_headers_win_base_y = value
    
    if header_sprite_active?
      if @header_type == :text
        @header_sprite.y = value + CONFIG::WINDOW_HEADERS::TEXT_OFFSET_Y
      else
        @header_sprite.y = value + CONFIG::WINDOW_HEADERS::IMAGE_OFFSET_Y
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Z Coordinate                                                [Alias]
  #--------------------------------------------------------------------------
  def z=(value)
    self.window_headers_win_base_z = value
    
    if header_sprite_active?
      @header_sprite.z = value + 1
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Visibility                                                  [Alias]
  #--------------------------------------------------------------------------
  def visible=(value)
    self.window_headers_win_base_visible = value
    
    if header_sprite_active?
      @header_sprite.visible = value && self.openness == 255
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Openness                                                    [Alias]
  #--------------------------------------------------------------------------
  def openness=(value)
    self.window_headers_win_base_openness = value
    
    if header_sprite_active?
      @header_sprite.visible = self.visible && value == 255
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Viewport                                                    [Alias]
  #--------------------------------------------------------------------------
  def viewport=(value)
    self.window_headers_win_base_viewport = value
    
    if header_sprite_active?
      @header_sprite.viewport = value
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Header Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def create_header_sprite
    return if header_sprite_active? || @header_created
    
    header_config = CONFIG::WINDOW_HEADERS::HEADERS[self.class]
    return unless header_config
    
    @header_sprite = Sprite.new(self.viewport)
    @header_sprite.z = self.z + 1
    @header_type = header_config[:type]
    @header_created = true
    
    if @header_type == :text
      create_text_header(header_config[:string])
    else
      @header_sprite.bitmap = Cache.header(header_config[:string])
    end
    
    update_header_position
    update_header_visibility
  end
  
  #--------------------------------------------------------------------------
  # * Create Text Header                                             [Custom]
  #--------------------------------------------------------------------------
  def create_text_header(text)
    settings = CONFIG::WINDOW_HEADERS::TEXT_SETTINGS
    text_width = text_size(text).width
    bitmap_width = text_width + 2
    bitmap_height = settings[:font_size] + 2
    bitmap = Bitmap.new(bitmap_width, bitmap_height)
    
    bitmap.font.name = settings[:font_name]
    bitmap.font.size = settings[:font_size]
    bitmap.font.bold = settings[:font_bold]
    bitmap.font.italic = settings[:font_italic]
    bitmap.font.outline = settings[:font_outline]
    bitmap.font.shadow = settings[:font_shadow]
    bitmap.font.color = Color.new(*settings[:color])
    bitmap.font.out_color = Color.new(*settings[:outline_color])
    
    bitmap.draw_text(1, 1, text_width, settings[:font_size], text, 0)
    @header_sprite.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # * Check if Header Sprite is Active                               [Custom]
  #--------------------------------------------------------------------------
  def header_sprite_active?
    @header_sprite && !@header_sprite.disposed?
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Header Sprite                                          [Custom]
  #--------------------------------------------------------------------------
  def dispose_header_sprite
    if header_sprite_active?
      @header_sprite.visible = false
      
      if @header_sprite.bitmap && !@header_sprite.bitmap.disposed?
        @header_sprite.bitmap.dispose
      end
      
      @header_sprite.dispose
      @header_sprite = nil
    end
    
    @header_created = false
  end
  
end # Window_Base

#==============================================================================
# 
# ▼ End of File
#
#==============================================================================