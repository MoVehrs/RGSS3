#==============================================================================
# ▼ Hammy - FF9 Dialog System v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 18.11.2025
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
#   - update_show_fast → ff9_dialog_win_msg_update_show_fast
#   - wait_for_one_character → ff9_dialog_win_msg_wait_one_char
#   - new_page → ff9_dialog_win_msg_new_page
#   - process_all_text → ff9_dialog_win_msg_process_all_text
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
    # - Default Bubble Arrow Sprites -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the sprite filenames for bubble arrow graphics. These sprites
    # point from the dialog window to the target character. All sprite files
    # should be placed in the Graphics/System folder and sized at 32x32 pixels.
    # 
    # down_left: Down-pointing arrow with left orientation
    # down_right: Down-pointing arrow with right orientation
    # up_left: Up-pointing arrow with left orientation
    # up_right: Up-pointing arrow with right orientation
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BUBBLE_ARROWS = {
      down_left: 'BubbleTag_Down_Left',
      down_right: 'BubbleTag_Down_Right',
      up_left: 'BubbleTag_Up_Left',
      up_right: 'BubbleTag_Up_Right'
    }.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Colored Bubble Arrow Sprites -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure colored bubble arrow sprites for integration with the Hammy
    # FF9 Windowskin System. These sprites automatically match the current
    # windowskin color theme when the system is active.
    # 
    # *_grey: Grey-themed arrow sprites for grey windowskins
    # *_blue: Blue-themed arrow sprites for blue windowskins
    # Available directions: up_left, up_right, down_left, down_right
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BUBBLE_ARROWS_COLORED = {
      up_left_grey: 'BubbleTag_Up_Left_Grey',
      up_right_grey: 'BubbleTag_Up_Right_Grey',
      down_left_grey: 'BubbleTag_Down_Left_Grey',
      down_right_grey: 'BubbleTag_Down_Right_Grey',
      up_left_blue: 'BubbleTag_Up_Left_Blue',
      up_right_blue: 'BubbleTag_Up_Right_Blue',
      down_left_blue: 'BubbleTag_Down_Left_Blue',
      down_right_blue: 'BubbleTag_Down_Right_Blue'
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
    if message_contains_chain_code?
      process_chained_messages
    else
      ff9_dialog_game_interpreter_command_101
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Message Contains Chain Code                       [Custom]
  #--------------------------------------------------------------------------
  def message_contains_chain_code?
    text_content = []
    command_list = @list
    current_index = @index + 1
    
    while current_index < command_list.size &&
          command_list[current_index].code == 401
      text_content << command_list[current_index].parameters[0]
      current_index += 1
    end
    
    !!(text_content.join('').match(/\\bmc\[/i))
  end
  
  #--------------------------------------------------------------------------
  # * Process Chained Messages                                       [Custom]
  #--------------------------------------------------------------------------
  def process_chained_messages
    wait_for_message
    message_params = @params
    $game_message.face_name = message_params[0]
    $game_message.face_index = message_params[1]
    $game_message.background = message_params[2]
    $game_message.position = message_params[3]
    
    collect_all_chained_messages.each do |message_text|
      $game_message.add(message_text)
    end
    
    handle_post_message_commands
    wait_for_message
  end
  
  #--------------------------------------------------------------------------
  # * Collect All Chained Messages                                   [Custom]
  #--------------------------------------------------------------------------
  def collect_all_chained_messages
    collected_messages = []
    current_index = @index
    command_list = @list
    
    while current_index < command_list.size
      command = command_list[current_index]
      break unless command.code == 101
      
      message_text, next_index = collect_single_message_text(current_index)
      
      if collected_messages.empty? ||
         !contains_forbidden_codes?(message_text)
        collected_messages << message_text
      else
        break
      end
      
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
    command_list = @list
    
    while current_index < command_list.size &&
          command_list[current_index].code == 401
      text_content << command_list[current_index].parameters[0]
      current_index += 1
    end
    
    if current_index < command_list.size
      case command_list[current_index].code
      when 102, 103, 104
        current_index += 1
      end
    end
    
    [text_content.join("\n"), current_index]
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Text Contains Forbidden Codes                     [Custom]
  #--------------------------------------------------------------------------
  def contains_forbidden_codes?(text)
    forbidden_patterns = [/\\bm\[/i, /\\bmc\[/i, /\\bmd\[/i, /\\bmp\[/i]
    forbidden_patterns.any? { |pattern| text.match(pattern) }
  end
  
  #--------------------------------------------------------------------------
  # * Handle Post Message Commands                                   [Custom]
  #--------------------------------------------------------------------------
  def handle_post_message_commands
    command_list = @list
    next_index = @index + 1
    return unless next_index < command_list.size
    
    case command_list[next_index].code
    when 102
      @index = next_index
      setup_choices(command_list[next_index].parameters)
    when 103
      @index = next_index
      setup_num_input(command_list[next_index].parameters)
    when 104
      @index = next_index
      setup_item_choice(command_list[next_index].parameters)
    end
  end
  
end # Game_Interpreter

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
    result = convert_specified_escape_characters(result)
    return result
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
    
    return result
  end
  
  #--------------------------------------------------------------------------
  # * Build Named Icon Escape Sequence                               [Custom]
  #--------------------------------------------------------------------------
  def escape_icon_item(data_id, type)
    case type
    when :item
      icon = $data_items[data_id].icon_index
      name = $data_items[data_id].name
    when :weapon
      icon = $data_weapons[data_id].icon_index
      name = $data_weapons[data_id].name
    when :armour
      icon = $data_armors[data_id].icon_index
      name = $data_armors[data_id].name
    when :skill
      icon = $data_skills[data_id].icon_index
      name = $data_skills[data_id].name
    when :state
      icon = $data_states[data_id].icon_index
      name = $data_states[data_id].name
    else
      return ""
    end
    
    return "\eI[#{icon}]" + name
  end
  
  #--------------------------------------------------------------------------
  # * Control Character Processing
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'PIC'
      text.sub!(/\[(.*?)\]/, "")
      bitmap = Cache.picture($1.to_s)
      rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      contents.blt(pos[:x], pos[:y], bitmap, rect)
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
    initialize_bubble_system
  end
  
  #--------------------------------------------------------------------------
  # * Initialize Bubble System                                       [Custom]
  #--------------------------------------------------------------------------
  def initialize_bubble_system
    @bubble_sprite = nil
    @event_id = nil
    @bubble_position = nil
    @bubble_direction = nil
    @intended_window_x = nil
    @intended_window_y = nil
    @is_bubble_mode = false
    @chain_mode = false
    load_bubble_config
  end
  
  #--------------------------------------------------------------------------
  # * Load Bubble Configuration                                      [Custom]
  #--------------------------------------------------------------------------
  def load_bubble_config
    position_config = CONFIG::FF9_DIALOG::BUBBLE_POSITION
    arrows_config = CONFIG::FF9_DIALOG::BUBBLE_ARROWS
    @bubble_config = position_config.merge(arrows_config)
  end
  
  #--------------------------------------------------------------------------
  # * Set X Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def x=(x)
    old_x = self.x
    super
    offset_x = self.x - old_x
    
    if offset_x != 0
      @character_sprites.each_key { |sprite| sprite.x += offset_x }
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Y Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def y=(y)
    old_y = self.y
    super
    offset_y = self.y - old_y
    
    if offset_y != 0
      @character_sprites.each_key { |sprite| sprite.y += offset_y }
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Z Coordinate                                                [Super]
  #--------------------------------------------------------------------------
  def z=(z)
    super
    z_value = self.z
    @character_sprites.each_key { |sprite| sprite.z = z_value }
  end
  
  #--------------------------------------------------------------------------
  # * Set Pause                                                       [Super]
  #--------------------------------------------------------------------------
  def pause=(value)
    @event_pop_id ? super(false) : super(value)
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
    return unless @is_scene_map && @event_pop_id
    
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
    if @bubble_sprite
      @bubble_sprite.bitmap.dispose if @bubble_sprite.bitmap
      @bubble_sprite.dispose
      @bubble_sprite = nil
    end
    
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
      bitmap = @bubble_sprite && @bubble_sprite.bitmap
      bubble_width = bitmap ? bitmap.width : 32
      bubble_center = character.screen_x + bubble_width / 2
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
    
    max_x = @graphics_width - self.width
    self.x = [[self.x, 0].max, max_x].min
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Y Position                                       [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_y(character)
    char_y = character.screen_y
    space_above = char_y
    space_below = @graphics_height - char_y
    
    bitmap = @bubble_sprite && @bubble_sprite.bitmap
    bubble_height = bitmap ? bitmap.height : 32
    required_space = self.height + bubble_height
    
    if required_space <= space_above
      self.y = @intended_window_y
    elsif required_space <= space_below
      self.y = char_y + @bubble_config[:y_offset_below]
    elsif space_above >= space_below
      self.y = @intended_window_y
    else
      self.y = char_y + @bubble_config[:y_offset_below]
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
    update_bubble_visibility if @bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Update Character Sprites                                       [Custom]
  #--------------------------------------------------------------------------
  def update_character_sprites
    @character_sprites.each do |sprite, parameters|
      next if parameters.empty?
      
      remaining_frames = parameters[0]
      total_frames = parameters[1]
      parameters[0] = @show_fast ? 0 : remaining_frames - 1
      
      if parameters[0] > 0
        sprite.opacity = 256 * (total_frames - parameters[0]) / total_frames
      else
        sprite_x = sprite.x - self.x - padding
        sprite_y = sprite.y - self.y - padding
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
    @bubble_sprite.visible = self.openness == 255 if @bubble_sprite
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
    while @char_timer < 60
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
    
    old_height = pos[:height]
    pos[:x] = pos[:new_x]
    pos[:y] += old_height
    
    if @compact_spacing
      next_line = text.slice(/^.*$/).to_s

      if next_line.strip.empty?
        pos[:height] = @compact_line_height
      else
        pos[:height] = calc_line_height(text)
      end
    else
      pos[:height] = calc_line_height(text)
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
    
    Fiber.yield until @show_fast || @character_sprites.all? do |*, params|
      params.empty?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adjust Pop Message                                             [Custom]
  #--------------------------------------------------------------------------
  def adjust_dialog(text = ' ')
    return unless @is_scene_map && @event_pop_id
    
    self.height = calculate_window_dimensions + standard_padding * 2
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
    if event_id && !target_character(event_id)
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
      break if @event_pop_id.nil? && Input.trigger?(:B)
    end
    
    Input.update
    self.pause = false
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Background and Position Changed                [Overwrite]
  #--------------------------------------------------------------------------
  def settings_changed?
    return true if @event_pop_id
    
    @background != $game_message.background ||
      @position != $game_message.position
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
      # Remove all control codes before width calculation
      temp_string = remove_control_codes_for_width(line)
      temp_string = convert_escape_characters(temp_string)
      # Remove escape sequences that may have been created during conversion
      temp_string = remove_escape_sequences(temp_string)
      icon_count = line.scan(/\\i\[\d{0,3}\]/).length
      text_width = text_size(temp_string).width + (icon_count * 24)
      
      self.width = [text_width + standard_padding * 2, self.width].max
      
      if @compact_spacing && line.strip.empty?
        total_height += @compact_line_height
      else
        total_height += line_height
      end
    end
    
    total_height
  end
  
  #--------------------------------------------------------------------------
  # * Remove Control Codes for Width Calculation                     [Custom]
  #--------------------------------------------------------------------------
  def remove_control_codes_for_width(text)
    result = text.dup
    # Remove icon codes first (handled separately with icon_count)
    result.gsub!(/\\i\[\d{0,3}\]/i, '')
    # Remove single-character control codes: \., \|, \$, \^, \!, \>, \<, \{, \}, \\, \A
    # These match the pattern from obtain_escape_code: \$\.\|\^!><\{\}\\
    result.gsub!(/\\([\.\|\$\^!><\{\}\\]|A)/i, '')
    # Remove multi-character control codes with brackets: \w[60], \sp[30], \ed[12], \C[1], etc.
    # Pattern: \ + one or more letters + [ + one or more digits + ]
    result.gsub!(/\\([A-Z]+)\[\d+\]/i, '')
    # Remove multi-character control codes without brackets (standalone codes like \C, \I, etc.)
    # Pattern: \ + one or more letters, not followed by [ or digit
    # Use negative lookahead to ensure we don't match codes that have brackets
    result.gsub!(/\\([A-Z]+)(?![\[\d])/i, '')
    result
  end
  
  #--------------------------------------------------------------------------
  # * Remove Escape Sequences After Conversion                        [Custom]
  #--------------------------------------------------------------------------
  def remove_escape_sequences(text)
    result = text.dup
    # Remove single-character escape codes: \e., \e|, \e$, \e^, \e!, \e>, \e<, \e{, \e}, \e\, \eA
    # After convert_escape_characters, \ becomes \e, so \. becomes \e.
    result.gsub!(/\e([\.\|\$\^!><\{\}\\]|A)/i, '')
    # Remove multi-character escape codes with brackets: \eW[60], \eSP[30], \eED[12], \eC[1], etc.
    result.gsub!(/\e([A-Z]+)\[\d+\]/i, '')
    # Remove multi-character escape codes without brackets
    # Use negative lookahead to ensure we don't match codes that have brackets
    result.gsub!(/\e([A-Z]+)(?![\[\d])/i, '')
    result
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Height                                          [Custom]
  #--------------------------------------------------------------------------
  def calculate_text_height
    all_text = $game_message.all_text
    return 0 unless all_text
    
    total_height = 0
    all_text.each_line do |line|
      if @compact_spacing && line.strip.empty?
        total_height += @compact_line_height
      else
        total_height += line_height
      end
    end
    
    [total_height, 1].max
  end
  
  #--------------------------------------------------------------------------
  # * Get Target Character                                           [Custom]
  #--------------------------------------------------------------------------
  def target_character(event_id)
    return nil unless event_id
    
    if event_id == 0
      $game_player
    elsif event_id > 0
      $game_map.events[event_id]
    else
      $game_player.followers[event_id.abs - 1]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Arrow Points Left                                 [Custom]
  #--------------------------------------------------------------------------
  def arrow_left?(character)
    return @bubble_direction == :left if @bubble_direction
    
    case character.direction
    when 4 then return false
    when 6 then return true
    end
    
    return true if @intended_window_x.nil? || self.x == @intended_window_x
    self.x < @intended_window_x
  end
  
  #--------------------------------------------------------------------------
  # * Create Bubble Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def create_bubble_sprite(vertical_up, horizontal_left, character)
    dispose_bubble_sprite
    
    @bubble_sprite = Sprite.new
    @bubble_sprite.z = self.z + 1
    
    sprite_name = bubble_sprite_name(vertical_up, horizontal_left)
    @bubble_sprite.bitmap = Cache.system(sprite_name)
    
    update_bubble_sprite_position(vertical_up, horizontal_left, character)
    update_bubble_visibility
  end
  
  #--------------------------------------------------------------------------
  # * Get Bubble Sprite Name                                         [Custom]
  #--------------------------------------------------------------------------
  def bubble_sprite_name(vertical_up, horizontal_left)
    direction = vertical_up ? :up : :down
    position = horizontal_left ? :left : :right
    base_key = "#{direction}_#{position}".to_sym
    
    if $imported[:hammy_ff9_windowskin_system]
      color = $game_system.windowskin_color == :blue ? :blue : :grey
      colored_key = "#{base_key}_#{color}".to_sym
      
      sprite_name = CONFIG::FF9_DIALOG::BUBBLE_ARROWS_COLORED[colored_key]
      return sprite_name if sprite_name
    end
    
    @bubble_config[base_key]
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Sprite Position                                  [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_sprite_position(vertical_up, horizontal_left, character)
    return unless @bubble_sprite && @bubble_sprite.bitmap
    
    bitmap = @bubble_sprite.bitmap
    
    if vertical_up
      @bubble_sprite.y = y - bitmap.height + 
                        @bubble_config[:tag_y_offset_above]
    else
      @bubble_sprite.y = y + self.height + 
                        @bubble_config[:tag_y_offset_below]
    end
    
    bubble_width = bitmap.width
    char_x = character.screen_x
    @bubble_sprite.x = horizontal_left ? char_x : char_x - bubble_width
    
    unless @bubble_direction
      adjust_bubble_sprite(vertical_up, horizontal_left, character,
                           bubble_width)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adjust Bubble Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def adjust_bubble_sprite(vertical_up, horizontal_left, character,
                           bubble_width)
    original_left = horizontal_left
    char_x = character.screen_x
    
    if char_x <= bubble_width
      horizontal_left = true
      @bubble_sprite.x = char_x
    elsif char_x >= @graphics_width - bubble_width
      horizontal_left = false
      @bubble_sprite.x = char_x - bubble_width
    end
    
    if horizontal_left != original_left
      sprite_name = bubble_sprite_name(vertical_up, horizontal_left)
      @bubble_sprite.bitmap = Cache.system(sprite_name)
    end
    
    max_x = @graphics_width - bubble_width
    @bubble_sprite.x = [[@bubble_sprite.x, 0].max, max_x].min
  end
  
  #--------------------------------------------------------------------------
  # * Normal Character Processing                                 [Overwrite]
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    draw_width = text_width * 2
    
    unless $game_system.message_fading
      draw_text(pos[:x], pos[:y], draw_width, pos[:height], c)
      pos[:x] += text_width
      wait_for_one_character
      return
    end
    
    if @show_fast || @text_speed == 0
      draw_text(pos[:x], pos[:y], draw_width, pos[:height], c)
      pos[:x] += text_width
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
    message_fading = $game_system.message_fading
    return super if @show_fast || @text_speed == 0 || !message_fading
    
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
    sprite, = @character_sprites.find {|*, params| params.empty? }
    
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
    parameters = []
    parameters << @effect_duration << @effect_duration
    @character_sprites[sprite] = parameters
    
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
    
    if code && code[0].upcase == 'A' && code.length > 1
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
      duration = obtain_escape_param(text)
      wait_message(duration) unless @show_fast
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
# 
# ▼ End of File
# 
#==============================================================================