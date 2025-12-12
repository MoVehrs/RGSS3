#==============================================================================
# ▼ Hammy - FF9 Choice Window v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 06.12.2025
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
# 06.12.2025 - Consolidated arrow images into a single spritesheet,
#              refactored bubble tag and shadow sprites into Sprite_BubbleTag
#              class for centralized management, cached shared sprite in
#              Scene_Map instead of recreating per window, added Hammy Window
#              Shadows compatibility, added auto-close timer, changed :B to
#              navigation shortcut (jumps to last choice), and general
#              optimizations. (v1.01)
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
#   - choice_timer (attr_reader)
#   - choice_use_index (attr_reader)
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
#   - process_handling
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
# ★ Alias Methods:
#   - start → ff9_choice_scene_map_start
#   - update → ff9_choice_scene_map_update
#   - terminate → ff9_choice_scene_map_terminate
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
# ★ choice_settings(text, x, y, type, bubble, timer, use_index)
#   Configures the choice window display settings before showing choices.
#   - text: Array of strings or hashes for text lines above choices
#           String format: 'Text content' (left-aligned by default)
#           Hash format: {text: 'Text content', align: :center/:left/:right}
#           Empty strings use half-height spacing for separation
#   - x: Optional horizontal position (nil for center, ignored if bubble mode)
#   - y: Optional vertical position (nil for center, ignored if bubble mode)
#   - type: Optional windowskin type (:default, :frame, :topbar, :help)
#           Requires Hammy FF9 Windowskin System
#   - bubble: Optional bubble configuration hash (default: {event_id: nil})
#             {:event_id}: Target character (0=player, positive=event,
#                          negative=follower)
#             {:event_id, :position}: Force vertical position (:above/:below)
#             {:event_id, :direction}: Force arrow direction (:left/:right)
#   - timer: Optional timer in frames (default: 0, 0 = disabled)
#            When > 0, window auto-closes after specified frames
#            Timer starts when window is fully opened (openness == 255)
#            Plays decision sound (Sound.play_ok) when timer expires
#   - use_index: Optional boolean (default: false)
#                When timer expires: true = use current selected index,
#                                   false = use cancel case (or last choice
#                                   if cancel is disabled)
#   - Returns: nil
# 
#   NOTE: :B input is now a navigation shortcut. Pressing :B will play the
#         cancel sound and jump to the last visible choice in the window.
#         This allows quick navigation to the bottom choice. Cancel case is
#         only accessible via timer expiration when use_index=false.
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
#                     {event_id: 0})
# 
#   - Bubble above event 5 with forced position
#     choice_settings([], nil, nil, nil,
#                     {event_id: 5, position: :above})
# 
#   - Bubble for first follower with forced left arrow
#     choice_settings([], nil, nil, nil,
#                     {event_id: -1, direction: :left})
# 
#   - Bubble below event 3 with right arrow
#     choice_settings(['Make your choice'], nil, nil, nil,
#                     {event_id: 3, position: :below,
#                     direction: :right})
# 
#   - Timer with auto-select current index after 180 frames (3 seconds at 60fps)
#     choice_settings(['Choose quickly!'], nil, nil, nil, nil, 180, true)
# 
#   - Timer with auto-cancel after 300 frames (5 seconds)
#     choice_settings(['Time is running out!'], nil, nil, nil, nil, 300, false)
#     Note: If cancel case exists, it will execute. If cancel is disabled,
#           the last choice in the list will be executed instead.
# 
#   - Timer with bubble and auto-select
#     choice_settings(['Quick decision!'], nil, nil, nil,
#                     {event_id: 0}, 120, true)
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
#   - has_potion: "p.has_item?($data_items[1])"
#   - early_game: "sys.playtime < 3600"
#   - high_level: "a1.level >= 50"
#   - rich: "p.gold >= 10000"
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
    CURSOR_OFFSET_X = 16
    WINDOW_MIN_WIDTH = 0
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
    #   has_potion: "p.has_item?($data_items[1])"
    #   early_game: "sys.playtime < 3600"
    #   high_level: "a1.level >= 50"
    #   rich: "p.gold >= 10000"
    #   in_town: "map.map_id == 5"
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    PREDEFINED_FORMULAS = {
      # :key_name: "condition_formula",
      # :another_key: "another_formula"
    }.freeze
    
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
  attr_reader :choice_timer
  attr_reader :choice_use_index
  
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
    @choice_timer = 0
    @choice_use_index = false
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
                      bubble = { event_id: nil }, timer = 0,
                      use_index = false)
    @choice_text = text
    @choice_x = x
    @choice_y = y
    @choice_type = type
    @choice_bubble = bubble
    @choice_timer = [timer, 0].max
    @choice_use_index = use_index
    
    return unless bubble.is_a?(Hash)
    
    @choice_event_id = bubble[:event_id]
    @choice_position = bubble[:position] if bubble.key?(:position)
    @choice_direction = bubble[:direction] if bubble.key?(:direction)
  end
  
  #--------------------------------------------------------------------------
  # * Reset Choice Settings                                          [Custom]
  #--------------------------------------------------------------------------
  def reset_choice_settings
    @choice_text = []
    @choice_x = nil
    @choice_y = nil
    @choice_type = nil
    @choice_bubble = { event_id: nil }
    @choice_event_id = nil
    @choice_position = nil
    @choice_direction = nil
    @choice_timer = 0
    @choice_use_index = false
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
    
    $game_message.choice_proc = proc do |choice|
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
  # * Choice Settings Helper Method                                  [Custom]
  #--------------------------------------------------------------------------
  def choice_settings(text = [], x = nil, y = nil, type = nil,
                      bubble = { event_id: nil }, timer = 0,
                      use_index = false)
    $game_message.choice_settings(text, x, y, type, bubble, timer, use_index)
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
      break if (@list[index].indent == current_indent) && 
               (@list[index].code == 404)
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
    return unless (scene.is_a?(Scene_Map) || scene.is_a?(Scene_Battle))
    
    message_window = scene.message_window
    return unless message_window
    
    Fiber.yield until message_window.close?
  end
  
end # Game_Interpreter

#==============================================================================
# ** Sprite_BubbleTag
#------------------------------------------------------------------------------
#  This sprite class manages bubble tag arrow sprites with optional shadow
#  support. It consolidates both the main bubble sprite and shadow sprite
#  into a single object for easier management.
#==============================================================================

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
      CONFIG::FF9_CHOICES
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
    sprite_name = if ($imported[:hammy_ff9_windowskin_system] && current_color)
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

end # Sprite_BubbleTag

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
    @line_height = CONFIG::FF9_CHOICES::LINE_HEIGHT
    @standard_padding = CONFIG::FF9_CHOICES::STANDARD_PADDING
    @cursor_offset_x = CONFIG::FF9_CHOICES::CURSOR_OFFSET_X
    @compact_spacing = CONFIG::FF9_CHOICES::COMPACT_SPACING
    @compact_line_height = CONFIG::FF9_CHOICES::COMPACT_LINE_HEIGHT
    @min_width = CONFIG::FF9_CHOICES::WINDOW_MIN_WIDTH
    @bubble_tag = nil
    @event_id = nil
    @bubble_position = nil
    @bubble_direction = nil
    @intended_window_x = nil
    @intended_window_y = nil
    @is_bubble_mode = false
    @filtered_choices = nil
    @timer_countdown = 0
    @timer_active = false
    @timer_started = false
    @bubble_config = CONFIG::FF9_CHOICES::BUBBLE_POSITION.dup
    
    ff9_choice_win_choice_initialize(message_window)
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
  # * Free                                                            [Alias]
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
    self.padding_bottom = standard_padding
  end
  
  #--------------------------------------------------------------------------
  # * Update Window Position                                      [Overwrite]
  #--------------------------------------------------------------------------
  def update_placement
    calc_window_dimensions
    
    @event_id = $game_message.choice_event_id
    @bubble_position = $game_message.choice_position
    @bubble_direction = $game_message.choice_direction
    
    scene = SceneManager.scene
    @is_bubble_mode = (@event_id && !scene.is_a?(Scene_Battle))
    
    if @is_bubble_mode
      unless @bubble_tag
        bubble_tag = scene.get_bubble_tag
        set_bubble_tag(bubble_tag)
      end
      
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
    
    self.x = (choice_x || ((@graphics_width  - self.width)  / 2))
    self.y = (choice_y || ((@graphics_height - self.height) / 2))
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
      bubble_center_x = character.screen_x + 16
      @intended_window_x = bubble_center_x - self.width / 2
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
  # * Start Input Processing                                      [Overwrite]
  #--------------------------------------------------------------------------
  def start
    @filtered_choices = nil
    clear_command_list
    make_command_list
    return $game_message.choice_proc.call(-1) if @list.empty?
    
    $game_message.choice_row_max = @list.size
    apply_windowskin_override($game_message.choice_type)
    
    @timer_countdown = $game_message.choice_timer
    @timer_active = @timer_countdown > 0
    @timer_started = false
    
    update_placement
    refresh
    select(0)
    open
    activate
  end
  
  #--------------------------------------------------------------------------
  # * Close Window                                                    [Alias]
  #--------------------------------------------------------------------------
  def close
    @timer_active = false
    @timer_countdown = 0
    @timer_started = false
    ff9_choice_bubble_close
    dispose_bubble_sprite
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_choice_bubble_update
    update_bubble_visibility if @bubble_tag
    update_timer if @timer_active
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
    if (condition_formula.is_a?(String) && condition_formula.start_with?(':'))
      symbol_key = condition_formula[1..-1].to_sym
      predefined = CONFIG::FF9_CHOICES::PREDEFINED_FORMULAS[symbol_key]
      
      unless predefined
        puts "Warning: Predefined formula :#{symbol_key} not found"
        return true
      end
      
      formula = predefined.dup
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
  # * Processing When Cancel Button Is Pressed                        [Super]
  #--------------------------------------------------------------------------
  def process_cancel
    return super if $game_message.choice_cancel_type % 5 == 0
    
    cancel_type = $game_message.choice_cancel_type - 1
    choice_index = @list.index { |command| command[:ext] == cancel_type }
    return unless choice_index
    
    if command_enabled?(choice_index)
      super
    else
      Sound.play_buzzer
    end
  end
  
  #--------------------------------------------------------------------------
  # * Handling Processing for OK and Cancel Etc.                  [Overwrite]
  #--------------------------------------------------------------------------
  def process_handling
    return unless (open? && active)
    return process_ok       if (ok_enabled?        && Input.trigger?(:C))
    return process_pagedown if (handle?(:pagedown) && Input.trigger?(:R))
    return process_pageup   if (handle?(:pageup)   && Input.trigger?(:L))
    return process_cancel_input if Input.trigger?(:B)
  end
  
  #--------------------------------------------------------------------------
  # * Process :B Input for Last Choice Navigation                    [Custom]
  #--------------------------------------------------------------------------
  def process_cancel_input
    Sound.play_cancel
    select(@list.size - 1) unless @list.empty?
  end
  
  #--------------------------------------------------------------------------
  # * Call OK Handler                                             [Overwrite]
  #--------------------------------------------------------------------------
  def call_ok_handler
    @timer_active = false
    @timer_countdown = 0
    $game_message.choice_proc.call(current_ext)
    close
    $game_message.reset_choice_settings
  end
  
  #--------------------------------------------------------------------------
  # * Call Cancel Handler                                             [Alias]
  #--------------------------------------------------------------------------
  def call_cancel_handler
    @timer_active = false
    @timer_countdown = 0
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
    return unless (cursor.width > 0 && cursor.height > 0)
    
    cursor.set(cursor.x + @cursor_offset_x, cursor.y + calc_text_height, 
               cursor.width - @cursor_offset_x, cursor.height)
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
    
    $game_message.choice_text.each do |text_line|
      if text_line.is_a?(Hash)
        text_content = text_line[:text]
        text_align = (text_line[:align] || :left)
      else
        text_content = text_line
        text_align = :left
      end
      
      next unless text_content
      x_position = calc_text_x_position(text_align, text_content)
      draw_text_ex(x_position, y_position, text_content)
      y_position += ((@compact_spacing && text_content.strip.empty?) ? 
                    @compact_line_height : line_height)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Window Height                                        [Custom]
  #--------------------------------------------------------------------------
  def calc_window_height
    total_lines, empty_lines = calc_total_lines
    text_area_lines = has_choice_text? ? $game_message.choice_text.size : 0
    choice_lines = ($game_message.choice_row_max || @list.size)
    display_lines = text_area_lines + choice_lines
    window_height = fitting_height(display_lines)
    
    if (@compact_spacing && empty_lines > 0)
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
        min_width = [min_width, calc_text_width(text_line)].max
      end
    end
    
    filtered_choices.each do |choice_data|
      total_width = calc_text_width(choice_data[:text]) + 
                    @cursor_offset_x + 4
      min_width = [min_width, total_width].max
    end
    
    self.width = [min_width + self.padding * 2, @graphics_width].min
    self.height = calc_window_height
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Width                                           [Custom]
  #--------------------------------------------------------------------------
  def calc_text_width(text)
    return 0 unless text
    
    text_content = text.is_a?(Hash) ? text[:text] : text
    return 0 if (text_content.nil? || text_content.empty?)
    
    icon_pattern = /\\i\[\d{0,3}\]/
    icon_count = text_content.scan(icon_pattern).length
    
    processed_text = text_content.dup
    processed_text.gsub!(/\\cc\[.*\](?!.*\])/i, '')
    processed_text.gsub!(/\\[^invpgINVPG]\[\d{0,3}\]/, '')
    processed_text.gsub!(icon_pattern, '')
    processed_text = convert_escape_characters(processed_text)
    
    text_size(processed_text).width + icon_count * 24
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Text Height                                          [Custom]
  #--------------------------------------------------------------------------
  def calc_text_height
    return 0 unless has_choice_text?
    total_height = 0
    
    $game_message.choice_text.each do |line|
      text_content = line.is_a?(Hash) ? line[:text] : line
      
      if (@compact_spacing && text_content && text_content.strip.empty?)
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
    case alignment
    when :left
      0
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
        empty_lines += 1 if (text_content && text_content.strip.empty?)
      end
    end
    
    total_lines += $game_message.choices.size
    [total_lines, empty_lines]
  end
  
  #--------------------------------------------------------------------------
  # * Update Timer                                                   [Custom]
  #--------------------------------------------------------------------------
  def update_timer
    unless @timer_started
      if self.openness == 255
        @timer_started = true
      else
        return
      end
    end
    
    @timer_countdown -= 1
    if @timer_countdown <= 0
      @timer_active = false
      handle_timer_expired
    end
  end
  
  #--------------------------------------------------------------------------
  # * Handle Timer Expired                                           [Custom]
  #--------------------------------------------------------------------------
  def handle_timer_expired
    Sound.play_ok
    deactivate
    Input.update
    
    if $game_message.choice_use_index
      if (@index >= 0 && @index < @list.size && command_enabled?(@index))
        $game_message.choice_proc.call(current_ext)
        close
        $game_message.reset_choice_settings
      else
        handle_timer_cancel
      end
    else
      handle_timer_cancel
    end
  end
  
  #--------------------------------------------------------------------------
  # * Handle Timer Cancel Case                                       [Custom]
  #--------------------------------------------------------------------------
  def handle_timer_cancel
    if $game_message.choice_cancel_type == 0
      if @list.empty?
        $game_message.choice_proc.call(-1)
      else
        last_index = @list.size - 1
        result = command_enabled?(last_index) ? 
                 @list[last_index][:ext] : -1
        $game_message.choice_proc.call(result)
      end
      
      close
      $game_message.reset_choice_settings
    else
      ff9_choice_win_choice_call_cncl_handlr
      $game_message.reset_choice_settings
    end
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
  # * Get Arrow Direction                                            [Custom]
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
  # * Update Bubble Visibility                                       [Custom]
  #--------------------------------------------------------------------------
  def update_bubble_visibility
    return unless @bubble_tag
    is_visible = (self.openness == 255 && @is_bubble_mode)
    @bubble_tag.visible = is_visible
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
  # * Get Choice Text Existence                                      [Custom]
  #--------------------------------------------------------------------------
  def has_choice_text?
    ($game_message.choice_text && !$game_message.choice_text.empty?)
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
      return unless [:default, :frame, :topbar, :help].include?(type)
    end
    
    color = $game_system.windowskin_color
    skin_name = CONFIG::FF9_WINDOWSKIN.get_windowskin(type, color)
    return if @windowskin_name == skin_name
    
    self.windowskin = Cache.system(skin_name)
    @windowskin_name = skin_name
    
    if ($imported[:hammy_window_shadows] && $game_system.window_shadows rescue false)
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
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_choice_scene_map_start, :start
  alias_method :ff9_choice_scene_map_update, :update
  alias_method :ff9_choice_scene_map_terminate, :terminate
  
  #--------------------------------------------------------------------------
  # * Start Processing                                                [Alias]
  #--------------------------------------------------------------------------
  def start
    ff9_choice_scene_map_start
    get_bubble_tag
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update                                                    [Alias]
  #--------------------------------------------------------------------------
  def update
    ff9_choice_scene_map_update
    @bubble_tag.update if @bubble_tag
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing                                          [Alias]
  #--------------------------------------------------------------------------
  def terminate
    dispose_bubble_tag if @bubble_tag
    ff9_choice_scene_map_terminate
  end
  
  #--------------------------------------------------------------------------
  # * Initialize Bubble Tag Sprite                                   [Custom]
  #--------------------------------------------------------------------------
  def initialize_bubble_tag
    return if @bubble_tag
    @bubble_tag = Sprite_BubbleTag.new(Window_ChoiceList)
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Bubble Tag Sprite                                      [Custom]
  #--------------------------------------------------------------------------
  def dispose_bubble_tag
    if @bubble_tag
      @bubble_tag.dispose
      @bubble_tag = nil
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Bubble Tag Sprite                                          [Custom]
  #--------------------------------------------------------------------------
  def get_bubble_tag
    initialize_bubble_tag unless @bubble_tag
    @bubble_tag
  end
  
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