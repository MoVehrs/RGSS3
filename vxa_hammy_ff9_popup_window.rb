#==============================================================================
# ▼ Hammy - FF9 Popup Window v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 31.10.2025
# -- Requires: None
# -- Recommended: Text Cache v1.04 by Mithran
# -- Credits: Vlue (Popup Window), Yanfly (Documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_ff9_popup] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 31.10.2025 - Added configurable compact spacing for empty lines. (v1.01)
# 26.10.2025 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an authentic Final Fantasy IX popup window system for
# RPG Maker VX Ace. It displays temporary popup windows with text content that
# can be closed by user input, perfect for notifications and item rewards.
# 
# The system supports escape codes for text formatting, per-line text alignment,
# custom positioning, configurable sound effect, integration with the Hammy FF9
# Windowskin System for type-based window appearance, and specialized helper
# methods for common popup types like item and gold rewards.
# 
# -----------------------------------------------------------------------------
# ► Core Popup Features
# -----------------------------------------------------------------------------
# ★ Key-controlled popup windows (C/B to close when fully open)
# ★ Custom window positioning with optional x/y coordinate override
# ★ Per-line text alignment (left, center, right) with mixed format support
# ★ Window type override support via Hammy FF9 Windowskin System integration
# 
# -----------------------------------------------------------------------------
# ► Helper Methods
# -----------------------------------------------------------------------------
# ★ Default popup display with custom text arrays
# ★ Item reward popups with automatic inventory management
# ★ Gold reward popups with automatic currency addition
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Player movement blocking during popup display
# ★ Dynamic window sizing based on text content
# ★ RGSS3-compliant escape code processing and rendering
# ★ Compact spacing mode for empty lines (half-height rendering)
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_Player (Class < Game_Character)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - ff9_popup_active (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → ff9_popup_game_sys_initialize
#   - update → ff9_popup_game_sys_update
# 
# -----------------------------------------------------------------------------
# ► Game_Interpreter (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - command_355 → ff9_popup_game_interpreter_command_355
# 
# -----------------------------------------------------------------------------
# ► Scene_Map (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - create_all_windows → ff9_popup_scene_base_create_all_windows
#   - update → ff9_popup_scene_base_update
#   - update_call_menu → ff9_popup_scene_base_update_call_menu
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains proper text formatting and escape code usage for
# optimal popup display results.
# 
# -----------------------------------------------------------------------------
# ► Text Formatting Guidelines
# -----------------------------------------------------------------------------
# When using escape codes in popup text, proper string formatting is essential
# for correct display of special characters, colors, and icons.
# 
# ★ Recommended: Use single quotes ('') for escape codes
#   Single quotes preserve backslashes without requiring double escaping
#   Example: default_popup(['\i[5] \c[14]Item received!\c[0]'])
# 
# ★ Alternative: Use double quotes ("") with double backslashes
#   Double quotes require escape characters to be doubled for proper parsing
#   Example: default_popup(["\\i[5] \\c[14]Item received!\\c[0]"])
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events.
# 
# -----------------------------------------------------------------------------
# ► Basic Popup Display
# -----------------------------------------------------------------------------
# ★ default_popup(['text line 1', 'text line 2'], x, y, type)
#   Displays a popup window with custom text content.
#   - text: Array of strings or hashes for each line of popup text
#           String format: "Text content" (left-aligned by default)
#           Hash format: {text: "Text content", align: :center/:left/:right}
#   - x: Optional horizontal position (nil for center)
#   - y: Optional vertical position (nil for center)
#   - type: Optional windowskin type (:default, :frame, :topbar, :help)
#   - Returns: nil
# 
# ★ Examples:
#   - Basic popup with single line and icon
#     default_popup(['\i[5] Mage class unlocked!'])
# 
#   - Two lines with custom position x=50, y=50
#     default_popup(['\c[16]Class Change:\c[0]', 'Speak to any hermit!'], 50, 50)
# 
#   - Mixed alignment: centered title with left-aligned text
#     default_popup([{text: 'Centered Title', align: :center}, 'Left text'])
# 
#   - Right-aligned text
#     default_popup([{text: 'Right Text', align: :right}])
# 
#   - Frame windowskin type (requires Hammy FF9 Windowskin System)
#     default_popup(['Special message!'], nil, nil, :frame)
# 
# -----------------------------------------------------------------------------
# ► Gold Reward Popups
# -----------------------------------------------------------------------------
# ★ gold_popup(amount, x, y, type)
#   Displays gold reward popup and adds gold to party.
#   - amount: Amount of gold to add to party funds
#   - x: Optional horizontal position (nil for center)
#   - y: Optional vertical position (nil for center)
#   - type: Optional windowskin type (:default, :frame, :topbar, :help)
#   - Returns: nil
# 
# ★ Examples:
#   - Add 100 gold
#     gold_popup(100)
# 
#   - Add 9999 gold at position x=200, y=100
#     gold_popup(9999, 200, 100)
# 
# -----------------------------------------------------------------------------
# ► Item Reward Popups
# -----------------------------------------------------------------------------
# ★ item_popup(item_id, quantity, x, y, type)
#   Displays item reward popup and adds items to inventory.
#   - item_id: Database ID of the item to reward
#   - quantity: Number of items to add (default: 1)
#   - x: Optional horizontal position (nil for center)
#   - y: Optional vertical position (nil for center)
#   - type: Optional windowskin type (:default, :frame, :topbar, :help)
#   - Returns: nil
# 
# ★ Examples:
#   - Add 1 of item ID 1
#     item_popup(1)
# 
#   - Add 3 of item ID 5 at position x=50, y=50
#     item_popup(5, 3, 50, 50)
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
# ★ Benefits for FF9 Popup Window:
#   - Accurate text width calculations for dynamic popup window sizing
#   - Fixes text_size measurement inconsistencies that affect window dimensions
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
# ★ If using Hammy FF9 Windowskin System, place this script ABOVE the
#   Windowskin System script.
#
# ★ If using Hammy Window Shadows, place this script ABOVE the Window Shadows
#   script.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** FF9 Popup Window Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the FF9 Popup Window system.
#==============================================================================

module CONFIG
  module FF9_POPUP
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Window Appearance Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the visual appearance and spacing of popup windows including
    # padding and border settings that control the window's internal layout.
    # 
    # LINE_HEIGHT: Height of each text line in pixels for popup windows
    #   Uses default font size by default, but can be set to any integer value
    # STANDARD_PADDING: Window padding size in pixels for popup windows
    #   Controls the internal spacing between window borders and content
    # HIGHLIGHT_COLOR: Text color ID for highlighted text in popup messages
    #   Uses RPG Maker VX Ace's standard color palette (0-31)
    # CURRENCY_NAME: Name of the currency displayed in gold reward popups
    #   Can be customized to match your game's currency system
    # COMPACT_SPACING: Enable compact spacing for empty text lines
    #   When true, empty text lines use reduced height spacing for separation
    # COMPACT_LINE_HEIGHT: Height for empty lines when compact spacing enabled
    #   Pixel height used for empty text lines when COMPACT_SPACING is true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LINE_HEIGHT = Font.default_size
    STANDARD_PADDING = 12
    HIGHLIGHT_COLOR = 14
    CURRENCY_NAME = "Gil"
    COMPACT_SPACING = true
    COMPACT_LINE_HEIGHT = 6
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Sound Effect Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the sound effect played when popup windows are closed by user
    # input. The sound file should be placed in the Audio/SE folder of your
    # project.
    # 
    # CLOSE_SOUND: Sound effect configuration for popup window closing
    #   nil - No sound effect will be played
    #   "filename" - Play filename.ogg at volume 80, pitch 100 (default values)
    #   ["filename", volume, pitch] - Play with custom volume and pitch values
    #     volume: 0-100 (sound volume level)
    #     pitch: 50-150 (sound pitch adjustment, 100 = normal)
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    CLOSE_SOUND = "Decision1"
    
  end # CONFIG::FF9_POPUP
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
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_accessor :ff9_popup_active
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_popup_game_sys_initialize, :initialize
  alias_method :ff9_popup_game_sys_update, :update
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    ff9_popup_game_sys_initialize
    @ff9_popup_active = false
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    return if @ff9_popup_active
    ff9_popup_game_sys_update
  end
  
end # Game_Player

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_popup_game_interpreter_command_355, :command_355
  
  #--------------------------------------------------------------------------
  # * Script Command Processing                                       [Alias]
  #--------------------------------------------------------------------------
  def command_355
    ff9_popup_game_interpreter_command_355
    wait_for_ff9_popup if SceneManager.scene.is_a?(Scene_Map)
  end
  
  #--------------------------------------------------------------------------
  # * Wait for FF9 Popup to Close                                    [Custom]
  #--------------------------------------------------------------------------
  def wait_for_ff9_popup
    Fiber.yield while $game_player.ff9_popup_active
  end
  
  #--------------------------------------------------------------------------
  # * Show Default Popup Window                                      [Custom]
  #--------------------------------------------------------------------------
  def default_popup(text, x = nil, y = nil, type = nil)
    return unless SceneManager.scene.is_a?(Scene_Map)
    SceneManager.scene.show_ff9_popup(text, x, y, type)
    wait_for_ff9_popup
  end
  
  #--------------------------------------------------------------------------
  # * Show Gold Received Popup Window                                [Custom]
  #--------------------------------------------------------------------------
  def gold_popup(amount, x = nil, y = nil, type = nil)
    return unless SceneManager.scene.is_a?(Scene_Map)
    
    $game_party.gain_gold(amount)
    color = CONFIG::FF9_POPUP::HIGHLIGHT_COLOR
    currency = CONFIG::FF9_POPUP::CURRENCY_NAME
    text = ["", "Received \\c[#{color}]#{amount} #{currency}\\c[0]!", ""]
    
    SceneManager.scene.show_ff9_popup(text, x, y, type)
    wait_for_ff9_popup
  end
  
  #--------------------------------------------------------------------------
  # * Show Item Received Popup Window                                [Custom]
  #--------------------------------------------------------------------------
  def item_popup(item_id, quantity = 1, x = nil, y = nil, type = nil)
    return unless SceneManager.scene.is_a?(Scene_Map)
    
    $game_party.gain_item($data_items[item_id], quantity)
    item_name = $data_items[item_id].name
    color = CONFIG::FF9_POPUP::HIGHLIGHT_COLOR
    
    if quantity > 1
      text = ["", "Received \\c[#{color}]#{quantity}x #{item_name}\\c[0]!", ""]
    else
      text = ["", "Received \\c[#{color}]#{item_name}\\c[0]!", ""]
    end
    
    SceneManager.scene.show_ff9_popup(text, x, y, type)
    wait_for_ff9_popup
  end
  
end # Game_Interpreter

#==============================================================================
# ** Window_FF9Popup
#------------------------------------------------------------------------------
#  This window displays popup messages with text content and rewards.
#==============================================================================

class Window_FF9Popup < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Super]
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 1, 1)
    self.openness = 0
    
    @text = []
    @offset_x = nil
    @offset_y = nil
    @windowskin_name = nil
    @compact_spacing = CONFIG::FF9_POPUP::COMPACT_SPACING
    @compact_line_height = CONFIG::FF9_POPUP::COMPACT_LINE_HEIGHT
  end
  
  #--------------------------------------------------------------------------
  # * Get Line Height                                             [Overwrite]
  #--------------------------------------------------------------------------
  def line_height
    CONFIG::FF9_POPUP::LINE_HEIGHT
  end
  
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size                                   [Overwrite]
  #--------------------------------------------------------------------------
  def standard_padding
    CONFIG::FF9_POPUP::STANDARD_PADDING
  end
  
  #--------------------------------------------------------------------------
  # * Update Bottom Padding                                       [Overwrite]
  #--------------------------------------------------------------------------
  def update_padding_bottom
    self.padding_bottom = padding
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents                         [Overwrite]
  #--------------------------------------------------------------------------
  def contents_height
    calculate_text_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Height                                          [Custom]
  #--------------------------------------------------------------------------
  def calculate_text_height
    return 0 unless @text && !@text.empty?
    
    total_height = 0
    @text.each do |line|
      string = line.is_a?(Hash) ? line[:text] : line
      if @compact_spacing && string && string.strip.empty?
        total_height += @compact_line_height
      else
        total_height += line_height
      end
    end
    
    total_height
  end
  
  #--------------------------------------------------------------------------
  # * Get Icon Width                                                 [Custom]
  #--------------------------------------------------------------------------
  def icon_width
    size = text_size(' ').width
    ' ' * (24 / size)
  end
  
  #--------------------------------------------------------------------------
  # * Refresh                                                        [Custom]
  #--------------------------------------------------------------------------
  def refresh(text = nil, x = nil, y = nil, type = nil)
    return unless text
    
    @text = text
    @text_widths = []
    @offset_x = x unless x.nil?
    @offset_y = y unless y.nil?
    
    apply_windowskin_override(type)
    
    total_height = calculate_window_dimensions
    self.height = total_height + standard_padding * 2
    
    if @offset_x.nil?
      self.x = Graphics.width / 2 - self.width / 2
    else
      self.x = @offset_x
    end
    
    if @offset_y.nil?
      self.y = Graphics.height / 2 - self.height / 2
    else
      self.y = @offset_y
    end
    
    create_contents
    contents.clear
    draw_all_text_lines
  end
  
  #--------------------------------------------------------------------------
  # * Clear                                                          [Custom]
  #--------------------------------------------------------------------------
  def clear
    @text = []
    @text_widths = []
    @offset_x = nil
    @offset_y = nil
    @windowskin_name = nil
    
    self.width = 1
    self.height = 1
    
    create_contents
    contents.clear
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Window Dimensions and Text Widths                    [Custom]
  #--------------------------------------------------------------------------
  def calculate_window_dimensions
    total_height = 0
    @text.each_with_index do |line, i|
      string = line.is_a?(Hash) ? line[:text] : line
      temp_string = string.gsub(/\\[^invpgINVPG]\[\d{0,3}\]/) { "" }
      temp_string = temp_string.gsub(/\\i\[\d{0,3}\]/) { "" }
      temp_string = convert_escape_characters(temp_string)
      icon_count = string.scan(/\\i\[\d{0,3}\]/).length
      text_width = text_size(temp_string).width + (icon_count * 24)
      
      @text_widths[i] = text_width
      self.width = [text_width + standard_padding * 2, self.width].max
      
      if @compact_spacing && string.strip.empty?
        total_height += @compact_line_height
      else
        total_height += line_height
      end
    end
    
    total_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text X Position for Alignment                        [Custom]
  #--------------------------------------------------------------------------
  def calculate_text_x_position(align, line_index)
    return 0 if align == :left
    
    text_width = @text_widths[line_index]
    content_width = contents.width
    
    case align
    when :center
      (content_width - text_width) / 2
    when :right
      content_width - text_width
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw All Text Lines                                            [Custom]
  #--------------------------------------------------------------------------
  def draw_all_text_lines
    current_y = 0
    @text.each_with_index do |line, i|
      if line.is_a?(Hash)
        string = line[:text]
        align = line[:align] || :left
      else
        string = line
        align = :left
      end
      
      x_pos = calculate_text_x_position(align, i)
      draw_text_ex(x_pos, current_y, string)
      
      if @compact_spacing && string.strip.empty?
        current_y += @compact_line_height
      else
        current_y += line_height
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Apply Windowskin Type Override                                 [Custom]
  #--------------------------------------------------------------------------
  def apply_windowskin_override(type)
    return unless $imported[:hammy_ff9_windowskin_system]
    
    if type.nil?
      type = CONFIG::FF9_WINDOWSKIN.get_window_type(self.class)
    else
      valid_types = [:default, :frame, :topbar, :help]
      return unless valid_types.include?(type)
    end
    
    color = $game_system.windowskin_color
    skin_name = CONFIG::FF9_WINDOWSKIN.get_windowskin(type, color)
    return if @windowskin_name == skin_name
    
    self.windowskin = Cache.system(skin_name)
    @windowskin_name = skin_name
    
    if $imported[:hammy_window_shadows] && shadow_window_active?
      @shadow_window.refresh(self, type)
    end
  end
  
end # Window_FF9Popup

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_popup_scene_base_create_all_windows, :create_all_windows
  alias_method :ff9_popup_scene_base_update, :update
  alias_method :ff9_popup_scene_base_update_call_menu, :update_call_menu
  
  #--------------------------------------------------------------------------
  # * Create All Windows                                              [Alias]
  #--------------------------------------------------------------------------
  def create_all_windows
    ff9_popup_scene_base_create_all_windows
    create_ff9_popup_window
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_popup_scene_base_update
    update_ff9_popup_window
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button                [Alias]
  #--------------------------------------------------------------------------
  def update_call_menu
    return if $game_player.ff9_popup_active
    ff9_popup_scene_base_update_call_menu
  end
  
  #--------------------------------------------------------------------------
  # * Create FF9 Popup Window                                        [Custom]
  #--------------------------------------------------------------------------
  def create_ff9_popup_window
    @ff9_popup_window = Window_FF9Popup.new
  end
  
  #--------------------------------------------------------------------------
  # * Update FF9 Popup Window                                        [Custom]
  #--------------------------------------------------------------------------
  def update_ff9_popup_window
    if @ff9_popup_window
      @ff9_popup_window.update
      
      if @ff9_popup_window.openness == 255 && ff9_popup_close_input?
        play_ff9_popup_close_sound
        @ff9_popup_window.close
      end
      
      if @ff9_popup_window.openness == 0 && $game_player.ff9_popup_active
        @ff9_popup_window.clear
        $game_player.ff9_popup_active = false
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Check FF9 Popup Close Input                                    [Custom]
  #--------------------------------------------------------------------------
  def ff9_popup_close_input?
    Input.trigger?(:C) || Input.trigger?(:B)
  end
  
  #--------------------------------------------------------------------------
  # * Show FF9 Popup Window                                          [Custom]
  #--------------------------------------------------------------------------
  def show_ff9_popup(text, x = nil, y = nil, type = nil)
    @ff9_popup_window.refresh(text, x, y, type)
    @ff9_popup_window.open
    $game_player.ff9_popup_active = true
  end
  
  #--------------------------------------------------------------------------
  # * Play FF9 Popup Close Sound                                     [Custom]
  #--------------------------------------------------------------------------
  def play_ff9_popup_close_sound
    sound_config = CONFIG::FF9_POPUP::CLOSE_SOUND
    return unless sound_config
    
    case sound_config
    when String
      RPG::SE.new(sound_config, 80, 100).play
    when Array
      filename, volume, pitch = sound_config
      volume ||= 80
      pitch ||= 100
      RPG::SE.new(filename, volume, pitch).play
    end
  end
  
end # Scene_Map

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================