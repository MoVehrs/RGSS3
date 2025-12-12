#==============================================================================
# ▼ Hammy - FF9 Dialog System v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 06.12.2025
# -- Requires: None
# -- Recommended: Text Cache v1.04 by Mithran
# -- Credits: Jupiter Penguin (Message Effects, fade effect),
#             Yami (Pop Message, base script),
#             Yanfly (Ace Message System, escape codes, documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_ff9_dialog_system] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 06.12.2025 - Consolidated arrow images into a single spritesheet,
#              refactored bubble tag and shadow sprites into Sprite_BubbleTag
#              class for centralized management, cached shared sprite in
#              Scene_Map instead of recreating per window, added Hammy Window
#              Shadows compatibility, and general optimizations. (v1.01)
# 18.11.2025 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an authentic Final Fantasy IX dialog system for RPG Maker
# VX Ace. It displays message windows with speech bubble positioning above
# characters, perfect for character dialogue and interactive conversations.
# 
# The system supports escape code-based bubble positioning, automatic window
# positioning above or below characters, custom arrow sprite direction control,
# message chaining for continuous dialogue, character fade-in effects for text
# display, configurable text speed and effect duration, and full integration
# with the Hammy FF9 Windowskin System for colored bubble arrows.
# 
# -----------------------------------------------------------------------------
# ► Core Dialog Features
# -----------------------------------------------------------------------------
# ★ Speech bubble positioning above or below characters with arrow sprites
# ★ Escape code-based bubble positioning with custom arrow and position control
# ★ Automatic positioning based on available screen space
# ★ Message chaining support for continuous dialogue sequences
# ★ Character fade-in effects for text display
# ★ Configurable text display speed and effect duration
# ★ Compact spacing mode for empty lines
# 
# -----------------------------------------------------------------------------
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Configurable bubble positioning offsets and arrow sprites
# ★ Configurable window display settings (line height, padding)
# ★ Enable/disable fade-in effects via script calls
# ★ Support for colored bubble arrows via Hammy FF9 Windowskin System
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Automatic bubble positioning with boundary corrections
# ★ Narrow window centering on bubble sprite for small windows
# ★ Dynamic window sizing based on text content
# ★ Pop messages require :C to advance, while default windows still support :B
# ★ Pop message pause sprite automatically hidden 
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
#   - message_speed (attr_accessor)
#   - message_duration (attr_accessor)
#   - message_fading (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → ff9_dialog_game_system_initialize
# 
# -----------------------------------------------------------------------------
# ► Game_Interpreter (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - command_101 → ff9_dialog_game_interpreter_command_101
# 
# -----------------------------------------------------------------------------
# ► Window_Base (Class < Window)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - convert_escape_characters → ff9_dialog_win_base_conv_esc_chars
#   - process_escape_character → ff9_dialog_win_base_proc_esc_char
# 
# -----------------------------------------------------------------------------
# ► Window_Message (Class < Window_Base)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → ff9_dialog_win_msg_initialize
#   - dispose → ff9_dialog_win_msg_dispose
#   - close → ff9_dialog_win_msg_close
#   - clear_flags → ff9_dialog_win_msg_clear_flags
#   - update_placement → ff9_dialog_win_msg_update_placement
#   - update → ff9_dialog_win_msg_update
#   - fiber_main → ff9_dialog_win_msg_fiber_main
#   - process_all_text → ff9_dialog_win_msg_process_all_text
#   - update_show_fast → ff9_dialog_win_msg_update_show_fast
#   - wait_for_one_character → ff9_dialog_win_msg_wait_one_char
#   - new_page → ff9_dialog_win_msg_new_page
#   - convert_escape_characters → ff9_dialog_win_msg_conv_esc_chars
#   - obtain_escape_code → ff9_dialog_win_msg_obtain_escape_code
#   - process_escape_character → ff9_dialog_win_msg_proc_esc_char
# 
# ★ Super Methods:
#   - x=
#   - y=
#   - z=
#   - pause=
#   - line_height
#   - standard_padding
#   - contents_height
#   - update_padding_bottom
#   - process_draw_icon
# 
# ★ Overwrite Methods:
#   - process_new_line
#   - input_pause
#   - settings_changed?
#   - new_line_x
#   - process_normal_character
# 
# -----------------------------------------------------------------------------
# ► Scene_Map (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - start → ff9_dialog_scene_map_start
#   - update → ff9_dialog_scene_map_update
#   - terminate → ff9_dialog_scene_map_terminate
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use anywhere in your game.
# 
# -----------------------------------------------------------------------------
# ► Message Effects Configuration
# -----------------------------------------------------------------------------
# ★ $game_system.message_speed = n
#   Sets the default text display speed to n characters per second.
#   - Minimum value is 0 (no maximum limit)
#   - Returns: nil
# 
# ★ $game_system.message_duration = n
#   Sets the default effect duration to n frames for character fade-in.
#   - Minimum value is 0 (no maximum limit)
#   - Returns: nil
# 
# ★ $game_system.message_fading = true
#   Enables fade-in effects for text display.
#   - Characters fade in with effect (default)
#   - Returns: nil
#
# ★ $game_system.message_fading = false
#   Disables fade-in effects for text display.
#   - Uses standard RGSS3 letter-by-letter drawing without effects
#   - Returns: nil
# 
# ★ Examples:
#   - Set text speed to 60 characters per second
#     $game_system.message_speed = 60
# 
#   - Set effect duration to 12 frames
#     $game_system.message_duration = 12
# 
#   - Disable fade-in effects
#     $game_system.message_fading = false
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains proper escape code usage and bubble positioning for
# optimal dialog display results.
# 
# -----------------------------------------------------------------------------
# ► Positioning Escape Code Usage
# -----------------------------------------------------------------------------
# Insert escape codes directly into your message window text to control bubble
# positioning and display helper information. Escape codes can be placed
# anywhere in the message text and will be processed before display.
# 
# ★ \bm[x] - Set bubble target character
#   Sets the message window to position as a bubble above/below character x.
#   - x = 0: Player character
#   - x = positive (1,2,3...): Map event with that ID
#   - x = negative (-1,-2,-3...): Follower (party member)
# 
# ★ \bmc[x] - Set bubble target character (chained mode)
#   Same as \bm[x] but enables message chaining for continuous dialogue.
#   Multiple consecutive "Show Text" commands will be merged into a single
#   message window when this code is present.
# 
# ★ \bmd[d] - Force bubble arrow direction
#   Forces the arrow sprite direction. Must be used after \bm[x] or \bmc[x].
#   - d = l or L: Left-pointing arrow
#   - d = r or R: Right-pointing arrow
# 
# ★ \bmp[p] - Force bubble position
#   Forces the window position relative to character. Must be used after
#   \bm[x] or \bmc[x].
#   - p = a or A: Above character
#   - p = b or B: Below character
# 
# ★ Examples:
#   - \bm[1]Hello there!
#   - \bmc[1]First line of dialogue.
#   - \bm[1]\bmd[l]Arrow points left.
#   - \bm[1]\bmp[b]Window forced below character.
# 
# -----------------------------------------------------------------------------
# ► Timing Escape Code Usage
# -----------------------------------------------------------------------------
# Insert escape codes that control text speed, effect duration, and pauses
# during message display. Use these to fine-tune pacing and input behavior.
# 
# ★ \sp[n] - Change text display speed
#   Changes text display speed to n characters per second.
#   Setting to 0 displays text instantly.
#   Resets to default when message window closes.
# 
# ★ \ed[n] - Change effect duration
#   Changes effect duration to n frames for character fade-in.
#   Resets to default when message window closes.
# 
# ★ \a - Disable instant text display
#   Disables instant text display with confirm key.
# 
# ★ \. - Wait 15 frames (quarter second pause)
#   Adds a brief pause in text display.
# 
# ★ \| - Wait 60 frames (one second pause)
#   Adds a longer pause in text display.
# 
# ★ \w[n] - Wait n frames
#   Adds a custom pause of n frames during text display.
# 
# ★ Examples:
#   - \sp[60]Fast text!
#   - \ed[12]Slower fade effect.
#   - \aText that can't be skipped.
#   - Hello\. There!
#   - Wait\| for it...
#   - \w[60]Pause for a second.
# 
# -----------------------------------------------------------------------------
# ► Database Escape Code Usage
# -----------------------------------------------------------------------------
# Insert escape codes that insert database names and icons directly into your
# message text. Use these for dynamic references to items, skills, states, etc.
# Available in all windows that render text.
# 
# ★ \nc[n] - Insert class name
#   Inserts the name of Class ID n from the database.
# 
# ★ \ni[n] - Insert item name
#   Inserts the name of Item ID n from the database.
# 
# ★ \nw[n] - Insert weapon name
#   Inserts the name of Weapon ID n from the database.
# 
# ★ \na[n] - Insert armor name
#   Inserts the name of Armor ID n from the database.
# 
# ★ \ns[n] - Insert skill name
#   Inserts the name of Skill ID n from the database.
# 
# ★ \nt[n] - Insert state name
#   Inserts the name of State ID n from the database.
# 
# ★ \ii[n] - Insert item icon and name
#   Inserts the icon and name for Item ID n.
# 
# ★ \iw[n] - Insert weapon icon and name
#   Inserts the icon and name for Weapon ID n.
# 
# ★ \ia[n] - Insert armor icon and name
#   Inserts the icon and name for Armor ID n.
# 
# ★ \is[n] - Insert skill icon and name
#   Inserts the icon and name for Skill ID n.
# 
# ★ \it[n] - Insert state icon and name
#   Inserts the icon and name for State ID n.
# 
# ★ Examples:
#   - \ni[1]Item ID 1's name appears here.
#   - \ii[1]Item ID 1's icon and name appear here.
# 
# -----------------------------------------------------------------------------
# ► Special Escape Code Usage
# -----------------------------------------------------------------------------
# Insert escape codes for special rendering. Use these to embed pictures at the
# current text position for inline images, markers, or UI hints. Available in
# all windows that render text.
# 
# ★ \pic[filename] - Draw picture
#   Draws the picture from Graphics/Pictures with the given filename at the
#   current text position.
# 
# ★ Example:
#   - \pic[some_pic]Show picture inside the message.
# 
# -----------------------------------------------------------------------------
# ► Message Chaining
# -----------------------------------------------------------------------------
# When using \bmc[x], multiple consecutive "Show Text" commands are
# automatically merged into a single message window. This allows for longer
# dialogue sequences without manual text line management.
# 
# Chaining stops when:
#   - A non-"Show Text" command is encountered
#   - A new message contains bubble positioning codes (\bm, \bmc, \bmd, \bmp)
# 
# -----------------------------------------------------------------------------
# ► Bubble Positioning Behavior
# -----------------------------------------------------------------------------
# When a bubble target is set via \bm[x] or \bmc[x], the window automatically:
#   - Positions itself above or below the character based on available space
#   - Centers horizontally on the character (or arrow sprite for narrow windows)
#   - Adjusts position to stay within screen bounds
#   - Displays an arrow sprite pointing to the character
# 
# For narrow windows (width < narrow_width), the window centers on the bubble
# arrow sprite rather than the character for better visual alignment.
# 
# Arrow direction is automatically determined by:
#   - Character facing direction (if facing left/right)
#   - Window position relative to intended position
#   - Screen boundary constraints
# 
# You can override automatic behavior using \bmd[] and \bmp[] escape codes.
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
# ★ Benefits for FF9 Dialog System:
#   - Accurate text width calculations for dynamic window sizing
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
# ★ If using Hammy Window Shadows, place this script ABOVE the
#   Window Shadows script.
# 
# ★ If using Hammy Window Headers, place this script ABOVE the 
#   Window Headers script.
# 
# ★ If using Hammy FF9 Choice Window, place this script BELOW the
#   Choice Window script.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** FF9 Dialog System Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the FF9 Dialog System.
#==============================================================================

module CONFIG
  module FF9_DIALOG
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Dialog Window Display Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the visual appearance and behavior of dialog windows including
    # text line spacing, padding, and window dimensions.
    # 
    # LINE_HEIGHT: Height of each text line in pixels for dialog windows
    #   Uses default font size by default, but can be set to any integer value
    # STANDARD_PADDING: Window padding size in pixels for dialog windows
    #   Controls the internal spacing between window borders and content
    # COMPACT_SPACING: Enable compact spacing for empty text lines
    #   When true, empty text lines use reduced height spacing for separation
    # COMPACT_LINE_HEIGHT: Height for empty lines when compact spacing enabled
    #   Pixel height used for empty text lines when COMPACT_SPACING is true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LINE_HEIGHT = Font.default_size
    STANDARD_PADDING = 12
    COMPACT_SPACING = true
    COMPACT_LINE_HEIGHT = 6
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Message Effects Display Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the visual appearance and behavior of message effects including
    # character fade-in animation duration and text display speed.
    # 
    # FADE_DURATION: Default effect duration in frames for character fade-in
    #   Controls how many frames it takes for characters to fully fade in
    # FADE_SPEED: Default text display speed in characters per second
    #   Controls how fast text characters appear on screen
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    FADE_DURATION = 6
    FADE_SPEED = 30
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Bubble Positioning Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the positioning offsets and thresholds for bubble-style dialog
    # windows. These settings control how dialog windows position themselves
    # relative to target characters.
    # 
    # y_offset_below: Vertical offset when window is positioned below character
    #   Distance in pixels from character screen_y to window top when below
    # y_offset_above: Vertical offset when window is positioned above character
    #   Distance in pixels from character screen_y to window bottom when above
    # tag_y_offset_below: Vertical offset when arrow is below window
    #   Distance in pixels from window bottom to arrow sprite position
    # tag_y_offset_above: Vertical offset when arrow is above window
    #   Distance in pixels from window top to arrow sprite position
    # narrow_width: Threshold width for narrow window centering mode
    #   Narrow windows center on arrow sprite rather than character
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BUBBLE_POSITION = {
      y_offset_below: 16,
      y_offset_above: -48,
      tag_y_offset_below: -10,
      tag_y_offset_above: 10,
      narrow_width: 56
    }.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Default Bubble Arrow Sprite -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the sprite filename for bubble arrow graphics. This sprite
    # sheet contains all four arrow directions in a 2x2 grid layout (64x64px).
    # The sprite file should be placed in the Graphics/System folder.
    # 
    # Sprite Sheet Layout (64x64 pixels):
    #   - (0-31, 0-31): up_left
    #   - (32-63, 0-31): up_right
    #   - (0-31, 32-63): down_left
    #   - (32-63, 32-63): down_right
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BUBBLE_SPRITESHEET = 'BubbleTag'.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Colored Bubble Arrow Sprites -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure colored bubble arrow sprite sheets for integration with the
    # Hammy FF9 Windowskin System. These sprite sheets automatically match the
    # current windowskin color theme when the system is active.
    # 
    # Each sprite sheet uses the same 2x2 grid layout as the default sprite.
    # 
    # grey: Grey-themed arrow sprite sheet for grey windowskins
    # blue: Blue-themed arrow sprite sheet for blue windowskins
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BUBBLE_ARROWS_COLORED = {
      grey: 'BubbleTag_Grey',
      blue: 'BubbleTag_Blue'
    }.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Shadow Spritesheet -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the shadow sprite filename for bubble tag arrows for integration
    # with Hammy Window Shadows. This sprite sheet contains all four arrow
    # directions in a 2x2 grid layout (64x64px). The sprite file should be
    # placed in the Graphics/System folder.
    # 
    # Shadow sprite sheet uses the same layout as the main bubble tag sprite.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SHADOW_SPRITESHEET = 'BubbleTag_Shadow'.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Bubble Tag Shadow Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure shadow sprite positioning and appearance for bubble tag arrows.
    # When Window Shadows script is active and enabled, a second shadow sprite
    # is created below the main bubble tag sprite (z-1) with configurable
    # offsets and opacity.
    # 
    # shadow_offset_x: Horizontal offset for shadow sprite in pixels
    #   Positive values move shadow to the right
    # shadow_offset_y: Vertical offset for shadow sprite in pixels
    #   Positive values move shadow downward
    # shadow_opacity: Opacity value for shadow sprite (0-255)
    #   Lower values create more transparent shadows
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SHADOW_POSITION = {
      shadow_offset_x: 2,
      shadow_offset_y: 2,
      shadow_opacity: 120
    }.freeze
    
  end # FF9_DIALOG
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
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_accessor :message_speed
  attr_accessor :message_duration
  attr_accessor :message_fading
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_dialog_game_system_initialize, :initialize
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    ff9_dialog_game_system_initialize
    
    @message_speed = CONFIG::FF9_DIALOG::FADE_SPEED
    @message_duration = CONFIG::FF9_DIALOG::FADE_DURATION
    @message_fading = true
  end
  
  #--------------------------------------------------------------------------
  # * Set Message Speed                                              [Custom]
  #--------------------------------------------------------------------------
  def message_speed=(value)
    @message_speed = [value, 0].max
  end
  
  #--------------------------------------------------------------------------
  # * Set Message Duration                                           [Custom]
  #--------------------------------------------------------------------------
  def message_duration=(value)
    @message_duration = [value, 0].max
  end
  
end # Game_System

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
  alias_method :ff9_dialog_game_interpreter_command_101, :command_101
  
  #--------------------------------------------------------------------------
  # * Show Text                                                       [Alias]
  #--------------------------------------------------------------------------
  def command_101
    return process_chained_messages if message_contains_chain_code?
    ff9_dialog_game_interpreter_command_101
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Message Contains Chain Code                       [Custom]
  #--------------------------------------------------------------------------
  def message_contains_chain_code?
    current_index = @index + 1
    
    while (current_index < @list.size && @list[current_index].code == 401)
      return true if @list[current_index].parameters[0].match(/\\bmc\[/i)
      current_index += 1
    end
    
    false
  end
  
  #--------------------------------------------------------------------------
  # * Process Chained Messages                                       [Custom]
  #--------------------------------------------------------------------------
  def process_chained_messages
    wait_for_message
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    
    collect_all_chained_messages.each { |text| $game_message.add(text) }
    
    handle_post_message_commands
    wait_for_message
  end
  
  #--------------------------------------------------------------------------
  # * Collect All Chained Messages                                   [Custom]
  #--------------------------------------------------------------------------
  def collect_all_chained_messages
    collected_messages = []
    current_index = @index
    
    while current_index < @list.size
      break unless @list[current_index].code == 101
      
      message_text, next_index = collect_single_message_text(current_index)
      has_forbidden = contains_forbidden_codes?(message_text)
      
      if (collected_messages.empty? && has_forbidden)
        @index = next_index - 1
        current_index = next_index
        next
      end
      
      break if (!collected_messages.empty? && has_forbidden)
      
      collected_messages << message_text
      @index = next_index - 1
      current_index = next_index
    end
    
    collected_messages
  end
  
  #--------------------------------------------------------------------------
  # * Collect Single Message Text                                    [Custom]
  #--------------------------------------------------------------------------
  def collect_single_message_text(start_index)
    text_content = []
    current_index = start_index + 1
    
    while (current_index < @list.size && @list[current_index].code == 401)
      text_content << @list[current_index].parameters[0]
      current_index += 1
    end
    
    if (current_index < @list.size && 
       [102, 103, 104].include?(@list[current_index].code))
      current_index += 1
    end
    
    [text_content.join("\n"), current_index]
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Text Contains Forbidden Codes                     [Custom]
  #--------------------------------------------------------------------------
  def contains_forbidden_codes?(text)
    [/\\bm\[/i, /\\bmc\[/i, /\\bmd\[/i, /\\bmp\[/i].any? do |pattern|
      text.match(pattern)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Handle Post Message Commands                                   [Custom]
  #--------------------------------------------------------------------------
  def handle_post_message_commands
    next_index = @index + 1
    return unless next_index < @list.size
    
    command_code = @list[next_index].code
    return unless [102, 103, 104].include?(command_code)
    
    @index = next_index
    params = @list[next_index].parameters
    
    case command_code
    when 102 then setup_choices(params)
    when 103 then setup_num_input(params)
    when 104 then setup_item_choice(params)
    end
  end
  
end # Game_Interpreter

#==============================================================================
# ** Sprite_BubbleTag
#------------------------------------------------------------------------------
#  This sprite class manages bubble tag arrow sprites with optional shadow
#  support. It consolidates both the main bubble sprite and shadow sprite
#  into a single object for easier management.
#==============================================================================

unless $imported[:hammy_ff9_choice_window]
  class Sprite_BubbleTag < Sprite
    #--------------------------------------------------------------------------
    # * Object Initialization                                          [Custom]
    #--------------------------------------------------------------------------
    def initialize(window_class)
      super(nil)
      @config_module = get_config_module(window_class)
      @shadow_sprite = nil
      @shadow_config = @config_module::SHADOW_POSITION.dup
      @bitmap_name = nil
      @shadow_bitmap_name = nil
      @last_windowskin_color = nil
      @last_shadow_enabled = nil
      @graphics_width = Graphics.width
      
      self.visible = false
      update_bitmaps
    end
    
    #--------------------------------------------------------------------------
    # * Get Config Module from Window Class                            [Custom]
    #--------------------------------------------------------------------------
    def get_config_module(window_class)
      case window_class
      when Window_ChoiceList
        CONFIG::FF9_CHOICES
      when Window_Message
        CONFIG::FF9_DIALOG
      else
        CONFIG::FF9_DIALOG
      end
    end
    
    #--------------------------------------------------------------------------
    # * Free                                                           [Custom]
    #--------------------------------------------------------------------------
    def dispose
      dispose_shadow
      super
    end
    
    #--------------------------------------------------------------------------
    # * Frame Update                                                   [Custom]
    #--------------------------------------------------------------------------
    def update
      super
      update_bitmaps
    end
    
    #--------------------------------------------------------------------------
    # * Update Bitmaps                                                 [Custom]
    #--------------------------------------------------------------------------
    def update_bitmaps
      current_color = $game_system.windowskin_color rescue nil
      window_shadows = $game_system.window_shadows rescue false
      current_shadows = ($imported[:hammy_window_shadows] && window_shadows)
      
      update_arrow_bitmap(current_color)
      update_shadow_bitmap(current_shadows)
      @last_shadow_enabled = current_shadows
    end
    
    #--------------------------------------------------------------------------
    # * Update Arrow Bitmap                                            [Custom]
    #--------------------------------------------------------------------------
    def update_arrow_bitmap(current_color)
      sprite_name = if ($imported[:hammy_ff9_windowskin_system] && 
                        current_color)
                      color = (current_color == :blue) ? :blue : :grey
                      (@config_module::BUBBLE_ARROWS_COLORED[color] || 
                      @config_module::BUBBLE_SPRITESHEET)
                    else
                      @config_module::BUBBLE_SPRITESHEET
                    end
      
      return if @bitmap_name == sprite_name
      self.bitmap = Cache.system(sprite_name)
      @bitmap_name = sprite_name
      @last_windowskin_color = current_color
    end
    
    #--------------------------------------------------------------------------
    # * Update Shadow Bitmap                                           [Custom]
    #--------------------------------------------------------------------------
    def update_shadow_bitmap(current_shadows)
      shadow_sprite_name = @config_module::SHADOW_SPRITESHEET
      
      if current_shadows
        unless @shadow_sprite
          @shadow_sprite = Sprite.new(viewport)
          @shadow_sprite.visible = false
          @shadow_sprite.opacity = @shadow_config[:shadow_opacity]
        end
        
        unless (@shadow_sprite.bitmap && 
               @shadow_bitmap_name == shadow_sprite_name)
          @shadow_sprite.bitmap = Cache.system(shadow_sprite_name)
          @shadow_bitmap_name = shadow_sprite_name
        end
      elsif (!current_shadows && @shadow_sprite)
        dispose_shadow
      end
    end
    
    #--------------------------------------------------------------------------
    # * Dispose Shadow Sprite                                          [Custom]
    #--------------------------------------------------------------------------
    def dispose_shadow
      if @shadow_sprite
        @shadow_sprite.dispose
        @shadow_sprite = nil
        @shadow_bitmap_name = nil
      end
    end
    
    #--------------------------------------------------------------------------
    # * Set Viewport                                                   [Custom]
    #--------------------------------------------------------------------------
    def viewport=(viewport)
      super
      @shadow_sprite.viewport = viewport if @shadow_sprite
    end
    
    #--------------------------------------------------------------------------
    # * Set Z Coordinate                                               [Custom]
    #--------------------------------------------------------------------------
    def z=(z)
      super
    end
    
    #--------------------------------------------------------------------------
    # * Set Shadow Z Coordinate                                        [Custom]
    #--------------------------------------------------------------------------
    def shadow_z=(z)
      @shadow_sprite.z = z if @shadow_sprite
    end
    
    #--------------------------------------------------------------------------
    # * Set Visibility                                                 [Custom]
    #--------------------------------------------------------------------------
    def visible=(visible)
      super
      
      if @shadow_sprite
        @shadow_sprite.visible = (visible && 
          $imported[:hammy_window_shadows] && 
          ($game_system.window_shadows rescue false))
      end
    end
    
    #--------------------------------------------------------------------------
    # * Set Source Rectangle                                           [Custom]
    #--------------------------------------------------------------------------
    def src_rect=(rect)
      super
      update_shadow_position if @shadow_sprite
    end
    
    #--------------------------------------------------------------------------
    # * Set Source Rectangle Coordinates                               [Custom]
    #--------------------------------------------------------------------------
    def set_src_rect(x, y, width, height)
      self.src_rect.set(x, y, width, height)
      
      if @shadow_sprite
        @shadow_sprite.src_rect.set(x, y, width, height)
      end
      
      update_shadow_position
    end
    
    #--------------------------------------------------------------------------
    # * Update Shadow Position                                         [Custom]
    #--------------------------------------------------------------------------
    def update_shadow_position
      return unless (@shadow_sprite && self.bitmap)
      
      source_rect = self.src_rect
      base_x = @shadow_config[:shadow_offset_x]
      base_y = @shadow_config[:shadow_offset_y]
      
      offset_x, offset_y = if (source_rect.x == 32 && source_rect.y == 32)
                             [base_x * 2, base_y]
                           elsif (source_rect.x == 0 && source_rect.y == 0)
                             [base_x * 2, 0]
                           else
                             [base_x, base_y]
                           end
      
      @shadow_sprite.x = self.x + offset_x
      @shadow_sprite.y = self.y + offset_y
    end
    
    #--------------------------------------------------------------------------
    # * Set Position                                                   [Custom]
    #--------------------------------------------------------------------------
    def set_position(x, y)
      self.x = x
      self.y = y
      
      update_shadow_position if @shadow_sprite
    end
    
    #--------------------------------------------------------------------------
    # * Get Shadow Sprite                                              [Custom]
    #--------------------------------------------------------------------------
    def shadow_sprite
      @shadow_sprite
    end
    
  end # unless $imported[:hammy_ff9_choice_window]
end # Sprite_BubbleTag

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_dialog_win_base_conv_esc_chars, :convert_escape_characters
  alias_method :ff9_dialog_win_base_proc_esc_char, :process_escape_character
  
  #--------------------------------------------------------------------------
  # * Preconvert Control Characters                                   [Alias]
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = ff9_dialog_win_base_conv_esc_chars(text)
    convert_specified_escape_characters(result)
  end
  
  #--------------------------------------------------------------------------
  # * Convert Additional Escape Characters                           [Custom]
  #--------------------------------------------------------------------------
  def convert_specified_escape_characters(result)
    result.gsub!(/\eNC\[(\d+)\]/i) { $data_classes[$1.to_i].name }
    result.gsub!(/\eNI\[(\d+)\]/i) { $data_items[$1.to_i].name }
    result.gsub!(/\eNW\[(\d+)\]/i) { $data_weapons[$1.to_i].name }
    result.gsub!(/\eNA\[(\d+)\]/i) { $data_armors[$1.to_i].name }
    result.gsub!(/\eNS\[(\d+)\]/i) { $data_skills[$1.to_i].name }
    result.gsub!(/\eNT\[(\d+)\]/i) { $data_states[$1.to_i].name }
    
    result.gsub!(/\eII\[(\d+)\]/i) { escape_icon_item($1.to_i, :item) }
    result.gsub!(/\eIW\[(\d+)\]/i) { escape_icon_item($1.to_i, :weapon) }
    result.gsub!(/\eIA\[(\d+)\]/i) { escape_icon_item($1.to_i, :armour) }
    result.gsub!(/\eIS\[(\d+)\]/i) { escape_icon_item($1.to_i, :skill) }
    result.gsub!(/\eIT\[(\d+)\]/i) { escape_icon_item($1.to_i, :state) }
    
    result
  end
  
  #--------------------------------------------------------------------------
  # * Build Named Icon Escape Sequence                               [Custom]
  #--------------------------------------------------------------------------
  def escape_icon_item(data_id, type)
    data_object = case type
                  when :item   then $data_items[data_id]
                  when :weapon then $data_weapons[data_id]
                  when :armour then $data_armors[data_id]
                  when :skill  then $data_skills[data_id]
                  when :state  then $data_states[data_id]
                  else return ''
                  end
    
    "\\eI[#{data_object.icon_index}]#{data_object.name}"
  end
  
  #--------------------------------------------------------------------------
  # * Control Character Processing                                    [Alias]
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    if code.upcase == 'PIC'
      text.sub!(/\[(.*?)\]/, '')
      bitmap = Cache.picture($1.to_s)
      contents.blt(pos[:x], pos[:y], bitmap, 
                   Rect.new(0, 0, bitmap.width, bitmap.height))
    else
      ff9_dialog_win_base_proc_esc_char(code, text, pos)
    end
  end
  
end # Window_Base

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_dialog_win_msg_initialize, :initialize
  alias_method :ff9_dialog_win_msg_dispose, :dispose
  alias_method :ff9_dialog_win_msg_close, :close
  alias_method :ff9_dialog_win_msg_clear_flags, :clear_flags
  alias_method :ff9_dialog_win_msg_update_placement, :update_placement
  alias_method :ff9_dialog_win_msg_update, :update
  alias_method :ff9_dialog_win_msg_fiber_main, :fiber_main
  alias_method :ff9_dialog_win_msg_process_all_text, :process_all_text
  alias_method :ff9_dialog_win_msg_wait_one_char, :wait_for_one_character
  alias_method :ff9_dialog_win_msg_new_page, :new_page
  alias_method :ff9_dialog_win_msg_update_show_fast, :update_show_fast
  alias_method :ff9_dialog_win_msg_obtain_escape_code, :obtain_escape_code
  alias_method :ff9_dialog_win_msg_proc_esc_char, :process_escape_character
  alias_method :ff9_dialog_win_msg_conv_esc_chars, :convert_escape_characters
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    @graphics_width = Graphics.width
    @graphics_height = Graphics.height
    @is_scene_map = SceneManager.scene_is?(Scene_Map)
    @line_height = CONFIG::FF9_DIALOG::LINE_HEIGHT
    @standard_padding = CONFIG::FF9_DIALOG::STANDARD_PADDING
    @compact_spacing = CONFIG::FF9_DIALOG::COMPACT_SPACING
    @compact_line_height = CONFIG::FF9_DIALOG::COMPACT_LINE_HEIGHT
    @character_sprites = {}
    @auto_skip_disabled = false
    
    ff9_dialog_win_msg_initialize
    
    @bubble_tag = nil
    @event_id = nil
    @bubble_position = nil
    @bubble_direction = nil
    @intended_window_x = nil
    @intended_window_y = nil
    @is_bubble_mode = false
    @chain_mode = false
    @bubble_config = CONFIG::FF9_DIALOG::BUBBLE_POSITION.dup
  end
  
  #--------------------------------------------------------------------------
  # * Set Bubble Tag Sprite                                          [Custom]
  #--------------------------------------------------------------------------
  def set_bubble_tag(bubble_tag)
    @bubble_tag = bubble_tag
    if @bubble_tag
      @bubble_tag.viewport = self.viewport
      @bubble_tag.z = self.z + 1
      @bubble_tag.shadow_z = self.z
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set X Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def x=(x)
    old_x = self.x
    super
    offset_x = self.x - old_x
    
    return if offset_x == 0
    @character_sprites.each_key { |sprite| sprite.x += offset_x }
  end
  
  #--------------------------------------------------------------------------
  # * Set Y Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def y=(y)
    old_y = self.y
    super
    offset_y = self.y - old_y
    
    return if offset_y == 0
    @character_sprites.each_key { |sprite| sprite.y += offset_y }
  end
  
  #--------------------------------------------------------------------------
  # * Set Z Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def z=(z)
    super
    @character_sprites.each_key { |sprite| sprite.z = self.z }
  end
  
  #--------------------------------------------------------------------------
  # * Set Pause                                                       [Super]
  #--------------------------------------------------------------------------
  def pause=(value)
    super(@event_pop_id ? false : value)
  end
  
  #--------------------------------------------------------------------------
  # * Free                                                            [Alias]
  #--------------------------------------------------------------------------
  def dispose
    ff9_dialog_win_msg_dispose
    dispose_character_sprites
  end
  
  #--------------------------------------------------------------------------
  # * Free Character Sprites                                         [Custom]
  #--------------------------------------------------------------------------
  def dispose_character_sprites
    @character_sprites.each_key do |sprite|
      sprite.bitmap.dispose if sprite.bitmap
      sprite.dispose
    end
    
    @character_sprites.clear
  end
  
  #--------------------------------------------------------------------------
  # * Close Window                                                    [Alias]
  #--------------------------------------------------------------------------
  def close
    ff9_dialog_win_msg_close
    return unless (@is_scene_map && @event_pop_id)
    @event_pop_id = nil
    @bubble_direction = nil
    @bubble_position = nil
    dispose_bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Clear Flag                                                      [Alias]
  #--------------------------------------------------------------------------
  def clear_flags
    ff9_dialog_win_msg_clear_flags
    reset_to_defaults
    @auto_disabled = @auto_skip_disabled
    @char_timer = 0
  end
  
  #--------------------------------------------------------------------------
  # * Reset Effect Settings                                          [Custom]
  #--------------------------------------------------------------------------
  def reset_to_defaults
    @effect_duration = $game_system.message_duration
    @text_speed = $game_system.message_speed
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Bubble Sprite                                          [Custom]
  #--------------------------------------------------------------------------
  def dispose_bubble_sprite
    @bubble_tag.visible = false if @bubble_tag
    @bubble_tag = nil
    @event_id = nil
    @is_bubble_mode = false
  end
  
  #--------------------------------------------------------------------------
  # * Get Line Height                                                 [Super]
  #--------------------------------------------------------------------------
  def line_height
    @event_pop_id ? @line_height : super
  end
  
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size                                       [Super]
  #--------------------------------------------------------------------------
  def standard_padding
    @event_pop_id ? @standard_padding : super
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents                             [Super]
  #--------------------------------------------------------------------------
  def contents_height
    @event_pop_id ? calculate_text_height : super
  end
  
  #--------------------------------------------------------------------------
  # * Update Bottom Padding                                           [Super]
  #--------------------------------------------------------------------------
  def update_padding_bottom
    return super unless @event_pop_id
    self.padding_bottom = standard_padding
  end
  
  #--------------------------------------------------------------------------
  # * Update Window Position                                          [Alias]
  #--------------------------------------------------------------------------
  def update_placement
    return ff9_dialog_win_msg_update_placement unless @is_scene_map
    
    @event_id = @event_pop_id
    @is_bubble_mode = !@event_id.nil?
    
    if @is_bubble_mode
      unless @bubble_tag
        bubble_tag = SceneManager.scene.get_bubble_tag
        set_bubble_tag(bubble_tag)
      end
      
      update_bubble_position
    else
      fix_default_message
      ff9_dialog_win_msg_update_placement
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Position                                         [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_position
    character = target_character(@event_id)
    return fix_default_message unless character
    
    calc_bubble_position(character)
    self.x = @intended_window_x
    self.y = @intended_window_y
    correct_bubble_bounds(character)
    
    vertical_up = self.y >= character.screen_y
    horizontal_left = arrow_left?(character)
    create_bubble_sprite(vertical_up, horizontal_left, character)
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Bubble Position                                      [Custom]
  #--------------------------------------------------------------------------
  def calc_bubble_position(character)
    if self.width < @bubble_config[:narrow_width]
      bubble_center = character.screen_x + 16
      @intended_window_x = bubble_center - self.width / 2
    else
      @intended_window_x = character.screen_x - self.width / 2
    end
    
    @intended_window_y = character.screen_y - self.height + 
                         @bubble_config[:y_offset_above]
  end
  
  #--------------------------------------------------------------------------
  # * Correct Bubble Bounds                                          [Custom]
  #--------------------------------------------------------------------------
  def correct_bubble_bounds(character)
    case @bubble_position
    when :above
      self.y = @intended_window_y
    when :below
      self.y = character.screen_y + @bubble_config[:y_offset_below]
    else
      update_bubble_y(character)
    end
    
    self.x = [[self.x, 0].max, @graphics_width - self.width].min
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Y Position                                       [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_y(character)
    char_screen_y = character.screen_y
    space_above = char_screen_y
    space_below = @graphics_height - char_screen_y
    required_space = self.height + 32
    
    if required_space <= space_above
      self.y = @intended_window_y
    elsif required_space <= space_below
      self.y = char_screen_y + @bubble_config[:y_offset_below]
    else
      self.y = space_above >= space_below ? @intended_window_y : 
               char_screen_y + @bubble_config[:y_offset_below]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Fix Default Message                                            [Custom]
  #--------------------------------------------------------------------------
  def fix_default_message
    dispose_bubble_sprite
    self.width = window_width
    self.height = window_height
    self.x = 0
    create_contents
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_dialog_win_msg_update
    update_character_sprites
    update_bubble_visibility if @bubble_tag
  end
  
  #--------------------------------------------------------------------------
  # * Update Character Sprites                                       [Custom]
  #--------------------------------------------------------------------------
  def update_character_sprites
    @character_sprites.each do |sprite, parameters|
      next if parameters.empty?
      remaining_frames, total_frames = parameters
      parameters[0] = @show_fast ? 0 : remaining_frames - 1
      
      if parameters[0] > 0
        sprite.opacity = (256 * (total_frames - parameters[0]) / total_frames)
      else
        sprite_x = (sprite.x - self.x - self.padding)
        sprite_y = (sprite.y - self.y - self.padding)
        contents.blt(sprite_x, sprite_y, sprite.bitmap, sprite.src_rect)
        sprite.bitmap.clear
        sprite.visible = false
        parameters.clear
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Visibility                                       [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_visibility
    return unless @bubble_tag
    is_visible = self.openness == 255
    @bubble_tag.visible = is_visible
  end
  
  #--------------------------------------------------------------------------
  # * Main Processing of Fiber                                        [Alias]
  #--------------------------------------------------------------------------
  def fiber_main
    ff9_dialog_win_msg_fiber_main
    dispose_character_sprites
    reset_to_defaults
    @auto_skip_disabled = false
  end
  
  #--------------------------------------------------------------------------
  # * Wait During Text Display                                       [Custom]
  #--------------------------------------------------------------------------
  def wait_message(duration)
    duration.times do
      update_show_fast
      return if @show_fast
      Fiber.yield
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Fast Forward Flag                                        [Alias]
  #--------------------------------------------------------------------------
  def update_show_fast
    ff9_dialog_win_msg_update_show_fast unless @auto_disabled
  end
  
  #--------------------------------------------------------------------------
  # * Wait After Output of One Character                              [Alias]
  #--------------------------------------------------------------------------
  def wait_for_one_character
    until @char_timer >= 60
      ff9_dialog_win_msg_wait_one_char
      @char_timer += @text_speed
    end
    
    @char_timer -= 60
  end
  
  #--------------------------------------------------------------------------
  # * New Page                                                        [Alias]
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    self.contents_opacity = 255
    ff9_dialog_win_msg_new_page(text, pos)
  end
  
  #--------------------------------------------------------------------------
  # * New Line Character Processing                               [Overwrite]
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    @line_show_fast = false
    pos[:x] = pos[:new_x]
    pos[:y] += pos[:height]
    pos[:height] = if (@compact_spacing && 
                       text.slice(/^.*$/).to_s.strip.empty?)
                     @compact_line_height
                   else
                     calc_line_height(text)
                   end
    
    if need_new_page?(text, pos)
      input_pause
      new_page(text, pos)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Process All Text                                                [Alias]
  #--------------------------------------------------------------------------
  def process_all_text
    @event_pop_id = nil
    all_text = $game_message.all_text
    convert_escape_characters(all_text)
    update_placement
    adjust_dialog(all_text)
    ff9_dialog_win_msg_process_all_text
    
    until (@show_fast || @character_sprites.all? { |*, params| params.empty? })
      Fiber.yield
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adjust Pop Message                                             [Custom]
  #--------------------------------------------------------------------------
  def adjust_dialog(text = ' ')
    return unless (@is_scene_map && @event_pop_id)
    self.height = calculate_window_dimensions + (standard_padding * 2)
    create_contents
    update_placement
  end
  
  #--------------------------------------------------------------------------
  # * Preconvert Control Characters                                   [Alias]
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = ff9_dialog_win_msg_conv_esc_chars(text)
    @auto_skip_disabled = !!result.match(/\eA/i)
    convert_dialog_escape_characters(result)
  end
  
  #--------------------------------------------------------------------------
  # * Process Message Escape Characters                              [Custom]
  #--------------------------------------------------------------------------
  def convert_dialog_escape_characters(text_result)
    text_result.gsub!(/\eBM\[([+-]?\d+)\]/i) do
      event_dialog_setup($1.to_i, false)
    end
    
    text_result.gsub!(/\eBMC\[([+-]?\d+)\]/i) do
      event_dialog_setup($1.to_i, true)
    end
    
    text_result.gsub!(/\eBMD\[([lLrR])\]/i) { bubble_direction_setup($1) }
    text_result.gsub!(/\eBMP\[([aAbB])\]/i) { bubble_position_setup($1) }
    text_result
  end
  
  #--------------------------------------------------------------------------
  # * Set Up Event Pop Message                                       [Custom]
  #--------------------------------------------------------------------------
  def event_dialog_setup(event_id, chain_mode = false)
    if (event_id && !target_character(event_id))
      @event_pop_id = nil
      @chain_mode = false
    else
      @event_pop_id = event_id
      @chain_mode = chain_mode
    end
    
    ''
  end
  
  #--------------------------------------------------------------------------
  # * Set Up Bubble Direction                                        [Custom]
  #--------------------------------------------------------------------------
  def bubble_direction_setup(direction_char)
    case direction_char.upcase
    when 'L' then @bubble_direction = :left
    when 'R' then @bubble_direction = :right
    end
    
    ''
  end
  
  #--------------------------------------------------------------------------
  # * Set Up Bubble Position                                         [Custom]
  #--------------------------------------------------------------------------
  def bubble_position_setup(position_char)
    case position_char.upcase
    when 'A' then @bubble_position = :above
    when 'B' then @bubble_position = :below
    end
    
    ''
  end
  
  #--------------------------------------------------------------------------
  # * Input Pause Processing                                      [Overwrite]
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    
    loop do
      Fiber.yield
      break if Input.trigger?(:C)
      break if (@event_pop_id.nil? && Input.trigger?(:B))
    end
    
    Input.update
    self.pause = false
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Background and Position Changed                [Overwrite]
  #--------------------------------------------------------------------------
  def settings_changed?
    return true if @event_pop_id
    (@background != $game_message.background || 
     @position != $game_message.position)
  end
  
  #--------------------------------------------------------------------------
  # * Get New Line Position                                       [Overwrite]
  #--------------------------------------------------------------------------
  def new_line_x
    return 0 if @event_pop_id
    $game_message.face_name.empty? ? 0 : 112
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Window Dimensions                                    [Custom]
  #--------------------------------------------------------------------------
  def calculate_window_dimensions
    all_text = $game_message.all_text
    return 0 unless all_text
    
    self.width = 1
    total_height = 0
    
    all_text.each_line do |line|
      temp_string = remove_control_codes_for_width(line)
      temp_string = convert_escape_characters(temp_string)
      temp_string = remove_escape_sequences(temp_string)
      icon_count = line.scan(/\\i\[\d{0,3}\]/).length
      text_width = text_size(temp_string).width + (icon_count * 24)
      
      self.width = [text_width + (standard_padding * 2), self.width].max
      total_height += ((@compact_spacing && line.strip.empty?) ? 
                       @compact_line_height : line_height)
    end
    
    total_height
  end
  
  #--------------------------------------------------------------------------
  # * Remove Control Codes for Width Calculation                     [Custom]
  #--------------------------------------------------------------------------
  def remove_control_codes_for_width(text)
    result = text.dup
    result.gsub!(/\\i\[\d{0,3}\]/i, '')
    result.gsub!(/\\([\.\|\$\^!><\{\}\\]|A)/i, '')
    result.gsub!(/\\([A-Z]+)\[\d+\]/i, '')
    result.gsub!(/\\([A-Z]+)(?![\[\d])/i, '')
    result
  end
  
  #--------------------------------------------------------------------------
  # * Remove Escape Sequences After Conversion                       [Custom]
  #--------------------------------------------------------------------------
  def remove_escape_sequences(text)
    result = text.dup
    result.gsub!(/\e([\.\|\$\^!><\{\}\\]|A)/i, '')
    result.gsub!(/\e([A-Z]+)\[\d+\]/i, '')
    result.gsub!(/\e([A-Z]+)(?![\[\d])/i, '')
    result
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Height                                          [Custom]
  #--------------------------------------------------------------------------
  def calculate_text_height
    return 0 unless $game_message.all_text
    total_height = 0
    
    $game_message.all_text.each_line do |line|
      total_height += ((@compact_spacing && line.strip.empty?) ? 
                       @compact_line_height : line_height)
    end
    
    [total_height, 1].max
  end
  
  #--------------------------------------------------------------------------
  # * Get Target Character                                           [Custom]
  #--------------------------------------------------------------------------
  def target_character(event_id)
    return unless event_id
    
    case
    when event_id == 0 then $game_player
    when event_id > 0 then $game_map.events[event_id]
    else $game_player.followers[event_id.abs - 1]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Arrow Points Left                                 [Custom]
  #--------------------------------------------------------------------------
  def arrow_left?(character)
    return @bubble_direction == :left if @bubble_direction
    return false if character.direction == 4
    return true if character.direction == 6
    return true if (@intended_window_x.nil? || self.x == @intended_window_x)
    
    self.x < @intended_window_x
  end
  
  #--------------------------------------------------------------------------
  # * Create Bubble Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def create_bubble_sprite(vertical_up, horizontal_left, character)
    return unless @bubble_tag
    
    x = horizontal_left ? 0 : 32
    y = vertical_up ? 0 : 32
    @bubble_tag.set_src_rect(x, y, 32, 32)
    
    update_bubble_sprite_position(vertical_up, horizontal_left, character)
    update_bubble_visibility
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Sprite Position                                  [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_sprite_position(vertical_up, horizontal_left, character)
    return unless (@bubble_tag && @bubble_tag.bitmap)
    
    @bubble_tag.z = self.z + 1
    @bubble_tag.shadow_z = self.z
    
    bubble_y = vertical_up ? 
               self.y - 32 + 
               @bubble_config[:tag_y_offset_above] : 
               self.y + self.height + @bubble_config[:tag_y_offset_below]
    
    char_screen_x = character.screen_x
    bubble_x = horizontal_left ? char_screen_x : char_screen_x - 32
    @bubble_tag.set_position(bubble_x, bubble_y)
    
    unless @bubble_direction
      adjust_bubble_sprite(vertical_up, horizontal_left, character)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adjust Bubble Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def adjust_bubble_sprite(vertical_up, horizontal_left, character)
    original_left = horizontal_left
    char_screen_x = character.screen_x
    max_x = @graphics_width - 32
    
    if char_screen_x <= 32
      horizontal_left = true
      bubble_x = char_screen_x
    elsif char_screen_x >= max_x
      horizontal_left = false
      bubble_x = char_screen_x - 32
    else
      bubble_x = @bubble_tag.x
    end
    
    if horizontal_left != original_left
      source_x = horizontal_left ? 0 : 32
      source_y = vertical_up ? 0 : 32
      @bubble_tag.set_src_rect(source_x, source_y, 32, 32)
    end
    
    bubble_x = [[bubble_x, 0].max, max_x].min
    @bubble_tag.set_position(bubble_x, @bubble_tag.y)
  end
  
  #--------------------------------------------------------------------------
  # * Normal Character Processing                                 [Overwrite]
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_width = text_width * 2
    
    if (!$game_system.message_fading || @show_fast || @text_speed == 0)
      draw_text(pos[:x], pos[:y], draw_width, pos[:height], c)
      pos[:x] += text_width
      wait_for_one_character unless $game_system.message_fading
      return
    end
    
    sprite = get_empty_sprite(pos)
    sprite.bitmap.font = contents.font.dup
    sprite.bitmap.draw_text(0, 0, draw_width, pos[:height], c)
    pos[:x] += text_width
    wait_for_one_character
  end
  
  #--------------------------------------------------------------------------
  # * Icon Drawing Process by Control Characters                      [Super]
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    return super if (@show_fast || @text_speed == 0 || 
                    !$game_system.message_fading)
    
    sprite = get_empty_sprite(pos)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    sprite.bitmap.blt(0, 0, bitmap, rect)
    pos[:x] += 24
    wait_for_one_character
  end
  
  #--------------------------------------------------------------------------
  # * Get Unused Character Sprite                                    [Custom]
  #--------------------------------------------------------------------------
  def get_empty_sprite(pos)
    sprite, = @character_sprites.find { |*, params| params.empty? }
    if sprite
      sprite.visible = true
      
      if sprite.bitmap.height < pos[:height]
        sprite.bitmap.dispose
        sprite.bitmap = nil
      end
    else
      sprite = Sprite.new(viewport)
      sprite.z = self.z
    end
    
    sprite.bitmap ||= Bitmap.new(pos[:height], pos[:height])
    @character_sprites[sprite] = [@effect_duration, @effect_duration]
    
    sprite.x = self.x + self.padding + pos[:x]
    sprite.y = self.y + self.padding + pos[:y]
    sprite.ox = sprite.oy = 0
    sprite.angle = 0
    sprite.zoom_x = sprite.zoom_y = 1.0
    sprite.opacity = 0
    sprite
  end
  
  #--------------------------------------------------------------------------
  # * Destructively Get Control Code                                  [Alias]
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    code = ff9_dialog_win_msg_obtain_escape_code(text)
    if (code && code[0].upcase == 'A' && code.length > 1)
      text.insert(0, code[1..-1])
      code = code[0]
    end
    
    code
  end
  
  #--------------------------------------------------------------------------
  # * Control Character Processing                                    [Alias]
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'W'
      wait_message(obtain_escape_param(text)) unless @show_fast
    when '.'
      wait_message(15) unless @show_fast
    when '|'
      wait_message(60) unless @show_fast
    when 'SP'
      @text_speed = obtain_escape_param(text)
    when 'ED'
      @effect_duration = obtain_escape_param(text)
    when 'A'
      @auto_disabled = true
    else
      ff9_dialog_win_msg_proc_esc_char(code, text, pos)
    end
  end
  
end # Window_Message

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  unless $imported[:hammy_ff9_choice_window]
    #------------------------------------------------------------------------
    # * Alias Method Definitions                                     [Custom]
    #------------------------------------------------------------------------
    alias_method :ff9_dialog_scene_map_start, :start
    alias_method :ff9_dialog_scene_map_update, :update
    alias_method :ff9_dialog_scene_map_terminate, :terminate
    
    #------------------------------------------------------------------------
    # * Start Processing                                              [Alias]
    #------------------------------------------------------------------------
    def start
      ff9_dialog_scene_map_start
      get_bubble_tag
    end
    
    #------------------------------------------------------------------------
    # * Frame Update                                                  [Alias]
    #------------------------------------------------------------------------
    def update
      ff9_dialog_scene_map_update
      @bubble_tag.update if @bubble_tag
    end
    
    #------------------------------------------------------------------------
    # * Termination Processing                                        [Alias]
    #------------------------------------------------------------------------
    def terminate
      dispose_bubble_tag if @bubble_tag
      ff9_dialog_scene_map_terminate
    end
    
    #------------------------------------------------------------------------
    # * Initialize Bubble Tag Sprite                                 [Custom]
    #------------------------------------------------------------------------
    def initialize_bubble_tag
      return if @bubble_tag
      @bubble_tag = Sprite_BubbleTag.new(Window_Message)
    end
    
    #------------------------------------------------------------------------
    # * Dispose Bubble Tag Sprite                                    [Custom]
    #------------------------------------------------------------------------
    def dispose_bubble_tag
      if @bubble_tag
        @bubble_tag.dispose
        @bubble_tag = nil
      end
    end
    
    #------------------------------------------------------------------------
    # * Get Bubble Tag Sprite                                        [Custom]
    #------------------------------------------------------------------------
    def get_bubble_tag
      initialize_bubble_tag unless @bubble_tag
      @bubble_tag
    end
    
  end # unless $imported[:hammy_ff9_choice_window]
end # Scene_Map

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================