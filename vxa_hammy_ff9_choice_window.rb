#==============================================================================
# ▼ Hammy - FF9 Choice Window v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 05.11.2025
# -- Requires: None
# -- Recommended: Text Cache v1.04 by Mithran
# -- Credits: Jupiter Penguin (ChoiceEX, merge and condition logic),
#             Yami (Pop Message, bubble tag logic),
#             Yanfly (Documentation style)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_ff9_choice_window] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 05.11.2025 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an authentic Final Fantasy IX choice window system for
# RPG Maker VX Ace. It displays choice windows with enhanced features including
# custom text display above choices, conditional choices, unlimited choice
# merging, bubble positioning, and full integration with the Hammy FF9
# Windowskin System.
# 
# The system supports custom text display above choices with escape code
# support, conditional choice visibility based on game state, automatic merging
# of consecutive choice commands to bypass the 4-choice limit, speech bubble
# positioning above characters, and custom window positioning with windowskin
# type override integration.
# 
# -----------------------------------------------------------------------------
# ► Core Choice Features
# -----------------------------------------------------------------------------
# ★ Delayed choice window opening after message window closure
# ★ Custom text display above choice commands with escape code support
# ★ Per-line text alignment (left, center, right) with mixed format support
# ★ Speech bubble positioning above characters with arrow sprites
# ★ Conditional choices using switches, variables, or Ruby expressions
# ★ Automatic merging of consecutive choice commands to bypass 4-choice limit
# ★ Custom window positioning with optional x/y coordinate override
# ★ Window type override support via Hammy FF9 Windowskin System
# 
# -----------------------------------------------------------------------------
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Configurable choice window display settings
# ★ Configurable compact spacing for empty text lines
# ★ Configurable bubble positioning offsets and arrow sprites
# ★ Support for complex conditions using game state references
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Automatic window centering when position not specified
# ★ Automatic bubble positioning with boundary corrections
# ★ Narrow window centering on bubble sprite for small windows
# ★ Settings auto-reset after choice window closure
# ★ Dynamic window sizing based on text content and choice commands
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_Message (Class)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - choice_row_max (attr_accessor)
#   - choice_text (attr_reader)
#   - choice_x (attr_reader)
#   - choice_y (attr_reader)
#   - choice_type (attr_reader)
#   - choice_bubble (attr_reader)
#   - choice_event_id (attr_reader)
#   - choice_position (attr_reader)
#   - choice_direction (attr_reader)
# 
# ★ Alias Methods:
#   - initialize → ff9_choice_game_message_initialize
#   - clear → ff9_choice_game_message_clear
# 
# -----------------------------------------------------------------------------
# ► Game_Interpreter (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - command_101 → ff9_choice_game_interpreter_command_101
# 
# ★ Overwrite Methods:
#   - setup_choices
#   - command_404
# 
# -----------------------------------------------------------------------------
# ► Window_ChoiceList (Class < Window_Command)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → ff9_choice_win_choice_initialize
#   - dispose → ff9_choice_bubble_dispose
#   - close → ff9_choice_bubble_close
#   - update → ff9_choice_bubble_update
#   - call_cancel_handler → ff9_choice_win_choice_call_cncl_handlr
#   - update_cursor → ff9_choice_win_choice_update_cursor
# 
# ★ Super Methods:
#   - process_cancel
# 
# ★ Overwrite Methods:
#   - line_height
#   - standard_padding
#   - contents_height
#   - update_padding_bottom
#   - update_placement
#   - start
#   - make_command_list
#   - call_ok_handler
#   - refresh
#   - draw_item
# 
# -----------------------------------------------------------------------------
# ► Scene_Map (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - message_window (attr_reader)
# 
# -----------------------------------------------------------------------------
# ► Scene_Battle (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - message_window (attr_reader)
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events.
# 
# -----------------------------------------------------------------------------
# ► Choice Window Configuration
# -----------------------------------------------------------------------------
# ★ choice_settings(text, x, y, type, bubble)
#   Configures the choice window display settings before showing choices.
#   - text: Array of strings or hashes for text lines above choices
#           String format: 'Text content' (left-aligned by default)
#           Hash format: {text: 'Text content', align: :center/:left/:right}
#           Empty strings use half-height spacing for separation
#   - x: Optional horizontal position (nil for center, ignored if bubble mode)
#   - y: Optional vertical position (nil for center, ignored if bubble mode)
#   - type: Optional windowskin type (:default, :frame, :topbar, :help)
#           Requires Hammy FF9 Windowskin System
#   - bubble: Optional bubble configuration hash (default: {:event_id => nil})
#             {:event_id}: Target character (0=player, positive=event,
#                          negative=follower)
#             {:event_id, :position}: Force vertical position (:above/:below)
#             {:event_id, :direction}: Force arrow direction (:left/:right)
#   - Returns: nil
# 
# ★ Examples:
#   - No text, centered window
#     choice_settings([], nil, nil)
# 
#   - Single text line with icon
#     choice_settings(['\i[5] Choose wisely!'])
# 
#   - Multiple lines with empty line separator (compact spacing)
#     choice_settings([
#       {text: '\c[14]Important Choice\c[0]', align: :center},
#       '',  # Empty line
#       'What will you do?'
#     ], 100, 200)
# 
#   - With frame windowskin type (requires Hammy FF9 Windowskin System)
#     choice_settings(['\c[14]Special\c[0]'], nil, nil, :frame)
# 
#   - Bubble above player character
#     choice_settings(['Choose an option'], nil, nil, nil,
#                     {:event_id => 0})
# 
#   - Bubble above event 5 with forced position
#     choice_settings([], nil, nil, nil,
#                     {:event_id => 5, :position => :above})
# 
#   - Bubble for first follower with forced left arrow
#     choice_settings([], nil, nil, nil,
#                     {:event_id => -1, :direction => :left})
# 
#   - Bubble below event 3 with right arrow
#     choice_settings(['Make your choice'], nil, nil, nil,
#                     {:event_id => 3, :position => :below,
#                     :direction => :right})
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains advanced choice system features including conditional
# choices, unlimited choice merging, and bubble positioning.
# 
# -----------------------------------------------------------------------------
# ► Bubble Positioning
# -----------------------------------------------------------------------------
# The bubble parameter enables speech bubble-style choice positioning above
# characters. When event_id is provided, the window automatically positions
# itself above or below the target character with an arrow sprite.
# 
# For narrow windows (width < narrow_width), the window centers on the bubble
# arrow sprite rather than the character for better visual alignment.
# 
# ★ Event ID values:
#   - 0: Player character
#   - Positive (1,2,3...): Map event with that ID
#   - Negative (-1,-2,-3...): Follower (party member)
# 
# ★ Position options:
#   - :above: Force window above character
#   - :below: Force window below character
#   - nil: Automatic positioning based on screen space
# 
# ★ Direction options:
#   - :left: Force left-pointing arrow
#   - :right: Force right-pointing arrow
#   - nil: Automatic based on character facing and window position
# 
# -----------------------------------------------------------------------------
# ► Conditional Choices
# -----------------------------------------------------------------------------
# Insert \cc[condition] in the choice text to hide choices based on game state.
# 
# Conditions are evaluated as Ruby code with the following shortcuts:
#   - sN: Reference to Switch #N (e.g., s1, s10, s999)
#   - vN: Reference to Variable #N (e.g., v5, v100)
#   - aN: Reference to Actor #N (e.g., a1, a2)
#   - p: Reference to $game_party
#   - sys: Reference to $game_system
#   - map: Reference to $game_map
#   - gp: Reference to $game_player
# 
# The control code can be placed as prefix or suffix in the choice text.
# If the "When Cancel" choice is hidden, it will be treated as disabled.
# 
# ★ Examples:
#   - Go to town \cc[s3]
#   - \cc[v10 >= 100]Buy sword
#   - Special option \cc[s5 && v3 > 2]
#   - Check gold \cc[p.gold >= 500]
#   - System check \cc[sys.playtime < 3600]
#   - Item check \cc[p.has_item?($data_items[1])]
#   - Map check \cc[map.map_id == 5]
#   - Player position \cc[gp.x > 10 && gp.y < 5]
#   - Actor check \cc[a1.level >= 10]
# 
# -----------------------------------------------------------------------------
# ► Predefined Formulas
# -----------------------------------------------------------------------------
# For complex conditions that are too long for the choice text input field or
# frequently reused, you can define formulas in the PREDEFINED_FORMULAS
# configuration hash and reference them by symbol.
# 
# Usage: \cc[:key_name] where :key_name is defined in PREDEFINED_FORMULAS
# 
# In CONFIG::FF9_CHOICES::PREDEFINED_FORMULAS:
#   - :has_potion => "p.has_item?($data_items[1])"
#   - :early_game => "sys.playtime < 3600"
#   - :high_level => "a1.level >= 50"
#   - :rich => "p.gold >= 10000"
# 
# ★ Examples:
#   - Buy potion \cc[:has_potion]
#   - Early game bonus \cc[:early_game]
#   - High level quest \cc[:high_level]
#   - Expensive item \cc[:rich]
# 
# -----------------------------------------------------------------------------
# ► Unlimited Choices
# -----------------------------------------------------------------------------
# Multiple consecutive "Show Choices" commands are automatically merged into a
# single choice window, extending beyond the default 4-choice limit.
# 
# ★ Merging Behavior:
#   - Consecutive choice commands are merged automatically
#   - When merging, non-"Disallow" cancel settings take priority
#   - If multiple cancel settings exist, the last one is used
#   - Add a comment or other command to prevent merging
#   - Window automatically resizes to show all available choices
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
# ★ Benefits for FF9 Choice Window:
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
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
# ★ If using Hammy FF9 Windowskin System, place this script ABOVE the
#   Windowskin System script.
# 
# ★ If using Hammy Window Shadows, place this script ABOVE the Window Shadows
#   script.
# 
# ★ If using Hammy Window Headers, place this script ABOVE the Window Headers
#   script.
# 
#==============================================================================

#==============================================================================
# ** FF9 Choice Window Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the FF9 Choice Window system.
#==============================================================================

module CONFIG
  module FF9_CHOICES
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Choice Window Display Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the visual appearance and behavior of choice windows including
    # text line spacing, padding, and cursor positioning.
    # 
    # LINE_HEIGHT: Height of each text line in pixels for choice windows
    #   Uses default font size by default, can be set to any integer value
    # STANDARD_PADDING: Window padding size in pixels for choice windows
    #   Controls the internal spacing between window borders and content
    # WINDOW_MIN_WIDTH: Minimum starting width for choice window calculations
    #   Prevents window from being too narrow, set to 0 for automatic width
    # CURSOR_OFFSET_X: Horizontal offset for the cursor in choice windows
    #   Controls the spacing between window edge and choice command text
    # COMPACT_SPACING: Enable compact spacing for empty text lines
    #   When true, empty text lines use half-height spacing for separation
    # COMPACT_LINE_HEIGHT: Height for empty lines when compact spacing enabled
    #   Pixel height used for empty text lines when COMPACT_SPACING is true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LINE_HEIGHT = Font.default_size
    STANDARD_PADDING = 12
    CURSOR_OFFSET_X = 0
    WINDOW_MIN_WIDTH = 64
    COMPACT_SPACING = true
    COMPACT_LINE_HEIGHT = 6
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Predefined Condition Formulas -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure reusable condition formulas that can be referenced by symbol
    # keys in choice conditions. Useful for complex conditions that are too
    # long for the choice text input field or frequently reused.
    # 
    # Usage in events: \\cc[:key_name] instead of the full formula
    # 
    # Example formulas:
    #   :has_potion => "p.has_item?($data_items[1])"
    #   :early_game => "sys.playtime < 3600"
    #   :high_level => "a1.level >= 50"
    #   :rich => "p.gold >= 10000"
    #   :in_town => "map.map_id == 5"
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    PREDEFINED_FORMULAS = {
      # :key_name => "condition_formula",
      # :another_key => "another_formula"
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Bubble Positioning Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the positioning offsets and thresholds for bubble-style choice
    # windows. These settings control how choice windows position themselves
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
      narrow_width: 80
    }
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Default Bubble Arrow Sprites -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the sprite filenames for bubble arrow graphics. These sprites
    # point from the choice window to the target character. All sprite files
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
    }
    
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
    }
    
  end # FF9_CHOICES
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
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that displays text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_accessor :choice_row_max
  attr_reader :choice_text
  attr_reader :choice_x
  attr_reader :choice_y  
  attr_reader :choice_type
  attr_reader :choice_bubble
  attr_reader :choice_event_id
  attr_reader :choice_position
  attr_reader :choice_direction
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_choice_game_message_initialize, :initialize
  alias_method :ff9_choice_game_message_clear, :clear
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    ff9_choice_game_message_initialize
    reset_choice_settings
    @choice_row_max = nil
  end
  
  #--------------------------------------------------------------------------
  # * Clear                                                           [Alias]
  #--------------------------------------------------------------------------
  def clear
    ff9_choice_game_message_clear
    reset_choice_settings
    @choice_row_max = nil
  end
  
  #--------------------------------------------------------------------------
  # * Set Choice Window Settings                                     [Custom]
  #--------------------------------------------------------------------------
  def choice_settings(text = [], x = nil, y = nil, type = nil,
                      bubble = {:event_id => nil})
    @choice_text = text
    @choice_x = x
    @choice_y = y
    @choice_type = type
    @choice_bubble = bubble
    
    if bubble.is_a?(Hash)
      @choice_event_id = bubble[:event_id]
      @choice_position = bubble[:position] if bubble.key?(:position)
      @choice_direction = bubble[:direction] if bubble.key?(:direction)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Reset Choice Settings                                          [Custom]
  #--------------------------------------------------------------------------
  def reset_choice_settings
    @choice_text = []
    @choice_x = nil
    @choice_y = nil
    @choice_type = nil
    @choice_bubble = {:event_id => nil}
    @choice_event_id = nil
    @choice_position = nil
    @choice_direction = nil
  end
  
end # Game_Message

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
  alias_method :ff9_choice_game_interpreter_command_101, :command_101
  
  #--------------------------------------------------------------------------
  # * Show Text                                                       [Alias]
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    
    while next_event_code == 401
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
    
    case next_event_code
    when 102
      @index += 1
      @pending_choice_params = @list[@index].parameters
    when 103
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    
    wait_for_message
    
    if @pending_choice_params
      wait_for_message_window_close
      setup_choices(@pending_choice_params)
      @pending_choice_params = nil
      Fiber.yield while $game_message.choice?
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup Choices                                               [Overwrite]
  #--------------------------------------------------------------------------
  def setup_choices(params)
    add_choices(params, @index)
    $game_message.choice_proc = Proc.new do |choice|
      @branch[@indent] = choice
    end
  end
  
  #--------------------------------------------------------------------------
  # * Branch End                                                  [Overwrite]
  #--------------------------------------------------------------------------
  def command_404
    return unless next_event_code == 102
    
    @branch[@indent] -= 5 if @branch.include?(@indent)
    @index += 1
    command_skip
  end
  
  #--------------------------------------------------------------------------
  # * Choice Settings Helper Method                                 [Custom]
  #--------------------------------------------------------------------------
  def choice_settings(text = [], x = nil, y = nil, type = nil,
                      bubble = {:event_id => nil})
    $game_message.choice_settings(text, x, y, type, bubble)
  end
  
  #--------------------------------------------------------------------------
  # * Add Choices                                                    [Custom]
  #--------------------------------------------------------------------------
  def add_choices(params, index, depth = 0)
    params[0].each_with_index do |choice_string, choice_index|
      $game_message.choices[choice_index + depth] = choice_string
    end
    
    $game_message.choice_cancel_type = params[1] + depth if params[1] > 0
    
    current_indent = @list[index].indent
    
    loop do
      index += 1
      if @list[index].indent == current_indent
        case @list[index].code
        when 404
          break
        end
      end
    end
    
    index += 1
    if @list[index].code == 102
      add_choices(@list[index].parameters, index, depth + 5)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait for Message Window Close                                  [Custom]
  #--------------------------------------------------------------------------
  def wait_for_message_window_close
    scene = SceneManager.scene
    return unless scene.is_a?(Scene_Map) || scene.is_a?(Scene_Battle)
    
    message_window = scene.message_window
    return unless message_window
    
    Fiber.yield until message_window.close?
  end
  
end # Game_Interpreter

#==============================================================================
# ** Window_ChoiceList
#------------------------------------------------------------------------------
#  This window is used for the event command [Show Choices].
#==============================================================================

class Window_ChoiceList < Window_Command
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_choice_win_choice_initialize, :initialize
  alias_method :ff9_choice_bubble_dispose, :dispose
  alias_method :ff9_choice_bubble_close, :close
  alias_method :ff9_choice_bubble_update, :update
  alias_method :ff9_choice_win_choice_call_cncl_handlr, :call_cancel_handler
  alias_method :ff9_choice_win_choice_update_cursor, :update_cursor
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize(message_window)
    @graphics_width = Graphics.width
    @graphics_height = Graphics.height
    @windowskin_name = nil
    
    choice_config = CONFIG::FF9_CHOICES
    @line_height = choice_config::LINE_HEIGHT
    @standard_padding = choice_config::STANDARD_PADDING
    @cursor_offset_x = choice_config::CURSOR_OFFSET_X
    @compact_spacing = choice_config::COMPACT_SPACING
    @compact_line_height = choice_config::COMPACT_LINE_HEIGHT
    @min_width = choice_config::WINDOW_MIN_WIDTH
    
    @bubble_sprite = nil
    @event_id = nil
    @position = nil
    @direction = nil
    @intended_window_x = nil
    @intended_window_y = nil
    @is_bubble_mode = false
    @filtered_choices = nil
    
    load_bubble_config
    ff9_choice_win_choice_initialize(message_window)
  end
  
  #--------------------------------------------------------------------------
  # * Dispose                                                         [Alias]
  #--------------------------------------------------------------------------
  def dispose
    dispose_bubble_sprite
    ff9_choice_bubble_dispose
  end
  
  #--------------------------------------------------------------------------
  # * Get Line Height                                             [Overwrite]
  #--------------------------------------------------------------------------
  def line_height
    @line_height
  end
  
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size                                   [Overwrite]
  #--------------------------------------------------------------------------
  def standard_padding
    @standard_padding
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents                         [Overwrite]
  #--------------------------------------------------------------------------
  def contents_height
    height = calc_text_height
    height += @list.size * item_height
    [height, 1].max
  end
  
  #--------------------------------------------------------------------------
  # * Update Bottom Padding                                       [Overwrite]
  #--------------------------------------------------------------------------
  def update_padding_bottom
    self.padding_bottom = padding
  end
  
  #--------------------------------------------------------------------------
  # * Update Window Position                                      [Overwrite]
  #--------------------------------------------------------------------------
  def update_placement
    calc_window_dimensions
    
    @event_id = $game_message.choice_event_id
    @position = $game_message.choice_position
    @direction = $game_message.choice_direction
    
    if SceneManager.scene.is_a?(Scene_Battle) && @event_id
      @is_bubble_mode = false
    else
      @is_bubble_mode = !@event_id.nil?
    end
    
    if @is_bubble_mode
      update_bubble_position
    else
      update_default_position
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Default Position                                        [Custom]
  #--------------------------------------------------------------------------
  def update_default_position
    choice_x = $game_message.choice_x
    choice_y = $game_message.choice_y
    
    if choice_x.nil? && choice_y.nil?
      self.x = (@graphics_width - self.width) / 2
      self.y = (@graphics_height - self.height) / 2
    elsif choice_x.nil?
      self.x = (@graphics_width - self.width) / 2
      self.y = choice_y
    elsif choice_y.nil?
      self.x = choice_x
      self.y = (@graphics_height - self.height) / 2
    else
      self.x = choice_x
      self.y = choice_y
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Position                                         [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_position
    character = target_character(@event_id)
    return update_default_position unless character
    
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
      bubble_width = @bubble_sprite && @bubble_sprite.bitmap ? 
                    @bubble_sprite.bitmap.width : 32
      bubble_center_x = character.screen_x + (bubble_width / 2)
      @intended_window_x = bubble_center_x - (self.width / 2)
    else
      @intended_window_x = character.screen_x - (self.width / 2)
    end
    
    @intended_window_y = character.screen_y - self.height + 
                        @bubble_config[:y_offset_above]
  end
  
  #--------------------------------------------------------------------------
  # * Correct Bubble Bounds                                          [Custom]
  #--------------------------------------------------------------------------
  def correct_bubble_bounds(character)
    if @position == :above
      self.y = @intended_window_y
    elsif @position == :below
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
    char_screen_y = character.screen_y
    space_above = char_screen_y
    space_below = @graphics_height - char_screen_y
    bubble_height = @bubble_sprite && @bubble_sprite.bitmap ? 
                    @bubble_sprite.bitmap.height : 32
    required_space = self.height + bubble_height
    
    if required_space <= space_above
      self.y = @intended_window_y
    elsif required_space <= space_below
      self.y = char_screen_y + @bubble_config[:y_offset_below]
    else
      if space_above >= space_below
        self.y = @intended_window_y
      else
        self.y = char_screen_y + @bubble_config[:y_offset_below]
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Start Input Processing                                      [Overwrite]
  #--------------------------------------------------------------------------
  def start
    @filtered_choices = nil
    clear_command_list
    make_command_list
    
    return $game_message.choice_proc.call(-1) if @list.empty?
    
    $game_message.choice_row_max = @list.size
    apply_windowskin_override($game_message.choice_type)
    
    update_placement
    refresh
    select(0)
    open
    activate
  end
  
  #--------------------------------------------------------------------------
  # * Close                                                           [Alias]
  #--------------------------------------------------------------------------
  def close
    ff9_choice_bubble_close
    dispose_bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Update                                                          [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_choice_bubble_update
    update_bubble_visibility if @bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Create Command List                                         [Overwrite]
  #--------------------------------------------------------------------------
  def make_command_list
    filtered_choices.each do |choice_data|
      add_command(choice_data[:text], :choice, true, choice_data[:index])
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Filtered Choices                                           [Custom]
  #--------------------------------------------------------------------------
  def filtered_choices
    @filtered_choices ||= begin
      choices = []
      $game_message.choices.each_with_index do |choice_option, choice_index|
        next unless choice_option
        
        choice_text = choice_option.dup
        condition_match = choice_text.match(/\\cc\[([^\]]+)\]/i)
        
        if condition_match
          condition = condition_match[1]
          choice_text.gsub!(/\\cc\[[^\]]+\]/i, '')
          choice_text.gsub!(/^\\/, '')
          next unless eval_condition(condition)
        end
        
        choices << { text: choice_text, index: choice_index }
      end
      
      choices
    end
  end
  
  #--------------------------------------------------------------------------
  # * Evaluate Condition                                             [Custom]
  #--------------------------------------------------------------------------
  def eval_condition(condition_formula)
    if condition_formula.is_a?(String) && condition_formula.start_with?(':')
      symbol_key = condition_formula[1..-1].to_sym
      predefined = CONFIG::FF9_CHOICES::PREDEFINED_FORMULAS[symbol_key]
      
      if predefined
        formula = predefined.dup
      else
        puts "Warning: Predefined formula :#{symbol_key} not found"
        return true
      end
    else
      formula = condition_formula.dup
    end
    
    formula.gsub!(/\bs(\d+)\b/) { "$game_switches[#{$1}]" }
    formula.gsub!(/\bv(\d+)\b/) { "$game_variables[#{$1}]" }
    formula.gsub!(/\ba(\d+)\b/) { "$game_actors[#{$1}]" }
    formula.gsub!(/\bp\b/, '$game_party')
    formula.gsub!(/\bsys\b/, '$game_system')
    formula.gsub!(/\bmap\b/, '$game_map')
    formula.gsub!(/\bgp\b/, '$game_player')
    
    begin
      eval(formula)
    rescue => error
      puts "Error evaluating condition: #{error.message}"
      puts "Formula: #{formula}"
      true
    end
  end
  
  #--------------------------------------------------------------------------
  # * Process Cancel Button                                           [Super]
  #--------------------------------------------------------------------------
  def process_cancel
    if $game_message.choice_cancel_type % 5 == 0
      super
    else
      cancel_type = $game_message.choice_cancel_type - 1
      choice_index = @list.index { |command| command[:ext] == cancel_type }
      
      if choice_index
        if command_enabled?(choice_index)
          super
        else
          Sound.play_buzzer
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Call OK Handler                                             [Overwrite]
  #--------------------------------------------------------------------------
  def call_ok_handler
    $game_message.choice_proc.call(current_ext)
    close
    $game_message.reset_choice_settings
  end
  
  #--------------------------------------------------------------------------
  # * Call Cancel Handler                                             [Alias]
  #--------------------------------------------------------------------------
  def call_cancel_handler
    ff9_choice_win_choice_call_cncl_handlr
    $game_message.reset_choice_settings
  end
  
  #--------------------------------------------------------------------------
  # * Update Cursor                                                   [Alias]
  #--------------------------------------------------------------------------
  def update_cursor
    ff9_choice_win_choice_update_cursor
    
    return unless @index >= 0
    
    cursor = cursor_rect
    return unless cursor.width > 0 && cursor.height > 0
    
    y_offset = calc_text_height
    new_x = cursor.x + @cursor_offset_x
    new_y = cursor.y + y_offset
    new_width = cursor.width - @cursor_offset_x
    
    cursor.set(new_x, new_y, new_width, cursor.height)
  end
  
  #--------------------------------------------------------------------------
  # * Refresh                                                     [Overwrite]
  #--------------------------------------------------------------------------
  def refresh
    create_contents
    draw_choice_text
    draw_all_items
  end
  
  #--------------------------------------------------------------------------
  # * Draw Item                                                   [Overwrite]
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect_for_text(index)
    rect.y += calc_text_height
    rect.x += @cursor_offset_x
    
    change_color(normal_color, command_enabled?(index))
    draw_text_ex(rect.x, rect.y, command_name(index))
  end
  
  #--------------------------------------------------------------------------
  # * Draw Choice Text                                               [Custom]
  #--------------------------------------------------------------------------
  def draw_choice_text
    return unless has_choice_text?
    
    y_position = 0
    
    $game_message.choice_text.each_with_index do |text_line, line_index|
      if text_line.is_a?(Hash)
        text_content = text_line[:text]
        text_align = text_line[:align] || :left
      else
        text_content = text_line
        text_align = :left
      end
      
      next unless text_content
      
      x_position = calc_text_x_position(text_align, text_content)
      draw_text_ex(x_position, y_position, text_content)
      
      if @compact_spacing && text_content.strip.empty?
        y_position += @compact_line_height
      else
        y_position += line_height
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Window Height                                        [Custom]
  #--------------------------------------------------------------------------
  def calc_window_height
    result = calc_total_lines
    total_lines = result[0]
    empty_lines = result[1]
    
    text_area_lines = has_choice_text? ? $game_message.choice_text.size : 0
    choice_lines = $game_message.choice_row_max || @list.size
    display_lines = text_area_lines + choice_lines
    
    window_height = fitting_height(display_lines)
    
    if @compact_spacing && empty_lines > 0
      window_height -= empty_lines * (line_height - @compact_line_height)
    end
    
    window_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Window Dimensions                                    [Custom]
  #--------------------------------------------------------------------------
  def calc_window_dimensions
    min_width = @min_width
    
    if has_choice_text?
      $game_message.choice_text.each do |text_line|
        text_width = calc_text_width(text_line)
        min_width = [min_width, text_width].max
      end
    end
    
    filtered_choices.each do |choice_data|
      total_width = calc_text_width(choice_data[:text])
      total_width += @cursor_offset_x + 4
      min_width = [min_width, total_width].max
    end
    
    self.width = [min_width + padding * 2, @graphics_width].min
    self.height = calc_window_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Width                                           [Custom]
  #--------------------------------------------------------------------------
  def calc_text_width(text)
    return 0 if text.nil? || text.empty?
    
    text_content = text.is_a?(Hash) ? text[:text] : text
    return 0 if text_content.nil? || text_content.empty?
    
    icon_pattern = /\\i\[\d{0,3}\]/
    icon_count = text_content.scan(icon_pattern).length
    
    processed_text = text_content.dup
    processed_text.gsub!(/\\cc\[.*\](?!.*\])/i, '')
    processed_text = processed_text.gsub(/\\[^invpgINVPG]\[\d{0,3}\]/, '')
    processed_text = processed_text.gsub(icon_pattern, '')
    processed_text = convert_escape_characters(processed_text)
    
    text_size(processed_text).width + (icon_count * 24)
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Height                                          [Custom]
  #--------------------------------------------------------------------------
  def calc_text_height
    return 0 unless has_choice_text?
    
    total_height = 0
    $game_message.choice_text.each do |line|
      text_content = line.is_a?(Hash) ? line[:text] : line
      
      if @compact_spacing && text_content && text_content.strip.empty?
        total_height += @compact_line_height
      else
        total_height += line_height
      end
    end
    
    total_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text X Position                                      [Custom]
  #--------------------------------------------------------------------------
  def calc_text_x_position(alignment, text_content)
    return 0 if alignment == :left
    
    case alignment
    when :center
      (contents.width - calc_text_width(text_content)) / 2
    when :right
      contents.width - calc_text_width(text_content)
    else
      0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Total Lines                                          [Custom]
  #--------------------------------------------------------------------------
  def calc_total_lines
    empty_lines = 0
    total_lines = has_choice_text? ? $game_message.choice_text.size : 0
    
    if has_choice_text?
      $game_message.choice_text.each do |line|
        text_content = line.is_a?(Hash) ? line[:text] : line
        empty_lines += 1 if text_content && text_content.strip.empty?
      end
    end
    
    total_lines += $game_message.choices.size
    
    [total_lines, empty_lines]
  end
  
  #--------------------------------------------------------------------------
  # * Load Bubble Configuration                                      [Custom]
  #--------------------------------------------------------------------------
  def load_bubble_config
    position_config = CONFIG::FF9_CHOICES::BUBBLE_POSITION
    arrows_config = CONFIG::FF9_CHOICES::BUBBLE_ARROWS
    @bubble_config = position_config.merge(arrows_config)
  end
  
  #--------------------------------------------------------------------------
  # * Get Target Character                                           [Custom]
  #--------------------------------------------------------------------------
  def target_character(event_id)
    return nil unless event_id
    
    case
    when event_id == 0
      $game_player
    when event_id > 0
      $game_map.events[event_id]
    else
      $game_player.followers[event_id.abs - 1]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Arrow Direction                                           [Custom]
  #--------------------------------------------------------------------------
  def arrow_left?(character)
    return @direction == :left if @direction
    
    case character.direction
    when 4
      return false
    when 6
      return true
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
      
      sprite_name = CONFIG::FF9_CHOICES::BUBBLE_ARROWS_COLORED[colored_key]
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
    char_screen_x = character.screen_x
    
    if horizontal_left
      @bubble_sprite.x = char_screen_x
    else
      @bubble_sprite.x = char_screen_x - bubble_width
    end
    
    unless @direction
      adjust_bubble_sprite(vertical_up, horizontal_left, 
                          character, bubble_width)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adjust Bubble Sprite                                           [Custom]
  #--------------------------------------------------------------------------
  def adjust_bubble_sprite(vertical_up, horizontal_left, 
                          character, bubble_width)
    original_horizontal_left = horizontal_left
    char_screen_x = character.screen_x
    
    if char_screen_x <= bubble_width
      horizontal_left = true
      @bubble_sprite.x = char_screen_x
    elsif char_screen_x >= @graphics_width - bubble_width
      horizontal_left = false
      @bubble_sprite.x = char_screen_x - bubble_width
    end
    
    if horizontal_left != original_horizontal_left
      sprite_name = bubble_sprite_name(vertical_up, horizontal_left)
      @bubble_sprite.bitmap = Cache.system(sprite_name)
    end
    
    @bubble_sprite.x = [[@bubble_sprite.x, 0].max,
                        @graphics_width - bubble_width].min
  end
  
  #--------------------------------------------------------------------------
  # * Update Bubble Visibility                                       [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_visibility
    return unless @bubble_sprite
    
    @bubble_sprite.visible = (self.openness == 255)
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
  # * Get Choice Text Existence                                      [Custom]
  #--------------------------------------------------------------------------
  def has_choice_text?
    $game_message.choice_text && !$game_message.choice_text.empty?
  end
  
  #--------------------------------------------------------------------------
  # * Apply Windowskin Override                                      [Custom]
  #--------------------------------------------------------------------------
  def apply_windowskin_override(type)
    return unless $imported[:hammy_ff9_windowskin_system]
    
    unless type
      type = CONFIG::FF9_WINDOWSKIN.get_window_type(self.class)
      return unless type
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
  
end # Window_ChoiceList

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_reader :message_window
  
end # Scene_Map

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_reader :message_window
  
end # Scene_Battle

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================