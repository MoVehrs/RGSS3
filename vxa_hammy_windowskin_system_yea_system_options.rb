#==============================================================================
# ▼ Hammy - FF9 Windowskin System - YEA System Options Addon v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 23.10.2025
# -- Requires: Hammy FF9 Windowskin System v1.00 or higher,
#              YEA-SystemOptions v1.00
# -- Optional: Theolized - Global System Option v1.00
# -- Credits: Yanfly (YEA-SystemOptions, Documentation style),
#             Theo Allen (Global System Option)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_ff9_windowskin_system_system_options] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 23.10.2025 - Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This addon extends the Yanfly System Options script to include windowskin
# color selection functionality for the Hammy FF9 Windowskin System. It
# provides seamless integration with the system options menu, allowing players
# to change the window color theme directly from the game's options screen.
# 
# The addon automatically detects whether Theo's Global System Option script is
# present and adapts its save behavior accordingly, supporting both standard
# save file storage and global options storage.
# 
# -----------------------------------------------------------------------------
# ► Core Integration Features
# -----------------------------------------------------------------------------
# ★ Windowskin color toggle command in System Options menu
# ★ Automatic detection of Global System Option script presence
# ★ Configurable command insertion position via anchor system
#
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► OptionData (Class)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - windowskin_color (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → ff9_windowskin_optiondata_initialize
# 
# -----------------------------------------------------------------------------
# ► Window_SystemOptions (Class < Window_Command)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - draw_item → ff9_windowskin_win_sysopt_draw_item
#   - cursor_change → ff9_windowskin_win_sysopt_cursor_change
#   - make_command_list → ff9_windowskin_win_sysopt_make_comm_list
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ Place this script BELOW YEA-SystemOptions and Hammy FF9 Windowskin System.
# 
# ★ If using Theolized Global System Option v1.0, windowskin color preferences
#   will be saved globally across all save files.
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
    # - System Options Anchor -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the insertion position for the windowskin color command in the
    # System Options menu. The command will be inserted after the specified
    # anchor command.
    # 
    # WINDOWSKIN_INSERT_ANCHOR: Symbol of the anchor command
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOWSKIN_INSERT_ANCHOR = :window_blu
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Command Vocabulary -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the display text and help information for the windowskin color
    # toggle command in the System Options menu.
    # 
    # WINDOWSKIN_VOCAB: Hash containing command text and help description
    #   [0] = Command name, [1] = Grey text, [2] = Blue text, [3] = Help text
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOWSKIN_VOCAB = {
      :windowskin_color => ["Window Color", "Grey", "Blue",
                            "Change the color scheme of all windows.\n" \
                            "Toggle between grey and blue window themes."
                           ]
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
    
    #--------------------------------------------------------------------------
    # * Merge Windowskin Color Vocabulary                              [Custom]
    #--------------------------------------------------------------------------
    if $imported["YEA-SystemOptions"]
      YEA::SYSTEM::COMMAND_VOCAB.merge!(WINDOWSKIN_VOCAB)
    end
    
  end # CONFIG::FF9_WINDOWSKIN
end # CONFIG

#==============================================================================
# ▼ Script Dependencies Check
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section checks for the presence of required companion scripts.
# If any required scripts are missing, it displays an error message and exits.
#==============================================================================

unless $imported["YEA-SystemOptions"]
  msgbox("YEA-System Options v1.00 by Yanfly is required but not found!\n" \
         "Please install the required script before using " \
         "Windowskin System - System Options Addon.")
  exit
end

unless $imported[:hammy_ff9_windowskin_system]
  msgbox("Hammy FF9 Windowskin System v1.00 is required but not found!\n" \
         "Please install the required script before using " \
         "Windowskin System - System Options Addon.")
  exit
end

#==============================================================================
# ** OptionData
#------------------------------------------------------------------------------
#  This class handles global system option data. It saves option preferences
# globally across all save files when using Theo's Global System Option.
#==============================================================================

if $imported[:Theo_GlobalOption]
  class OptionData
    #--------------------------------------------------------------------------
    # * Public Instance Variables                                      [Custom]
    #--------------------------------------------------------------------------
    attr_accessor :windowskin_color
    
    #--------------------------------------------------------------------------
    # * Alias Method Definitions                                       [Custom]
    #--------------------------------------------------------------------------
    alias_method :ff9_windowskin_optiondata_initialize, :initialize
    
    #--------------------------------------------------------------------------
    # * Object Initialization                                           [Alias]
    #--------------------------------------------------------------------------
    def initialize
      ff9_windowskin_optiondata_initialize
      @windowskin_color = :grey
    end
    
  end # OptionData
end # if $imported[:Theo_GlobalOption]

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Get Windowskin Color                                           [Custom]
  #--------------------------------------------------------------------------
  def windowskin_color
    if $imported[:Theo_GlobalOption]
      return $option_data.windowskin_color
    else
      return @windowskin_color
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Windowskin Color                                           [Custom]
  #--------------------------------------------------------------------------
  def windowskin_color=(value)
    if $imported[:Theo_GlobalOption]
      $option_data.windowskin_color = value
      OptionData.save
    else
      @windowskin_color = value
    end
  end
  
end # Game_System

#==============================================================================
# ** Window_SystemOptions
#------------------------------------------------------------------------------
#  This window displays system options on the options screen.
#==============================================================================

class Window_SystemOptions < Window_Command
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :ff9_windowskin_win_sysopt_draw_item, :draw_item
  alias_method :ff9_windowskin_win_sysopt_cursor_change, :cursor_change
  alias_method :ff9_windowskin_win_sysopt_make_comm_list, :make_command_list
  
  #--------------------------------------------------------------------------
  # * Create Command List                                             [Alias]
  #--------------------------------------------------------------------------
  def make_command_list
    ff9_windowskin_win_sysopt_make_comm_list
    inject_windowskin_color_command
  end
  
  #--------------------------------------------------------------------------
  # * Inject Windowskin Color Command                                [Custom]
  #--------------------------------------------------------------------------
  def inject_windowskin_color_command
    anchor_index = @list.find_index { |item| 
      item[:symbol] == CONFIG::FF9_WINDOWSKIN::WINDOWSKIN_INSERT_ANCHOR 
    }
    
    if anchor_index
      insert_index = anchor_index + 1
    else
      insert_index = @list.size
    end
    
    vocab = YEA::SYSTEM::COMMAND_VOCAB
    
    windowskin_command = {
      :name => vocab[:windowskin_color][0],
      :symbol => :windowskin_color,
      :enabled => true,
      :ext => nil
    }
    
    @list.insert(insert_index, windowskin_command)
    @help_descriptions[:windowskin_color] = vocab[:windowskin_color][3]
  end
  
  #--------------------------------------------------------------------------
  # * Draw Item                                                       [Alias]
  #--------------------------------------------------------------------------
  def draw_item(index)
    if @list[index][:symbol] == :windowskin_color
      reset_font_settings
      rect = item_rect(index)
      contents.clear_rect(rect)
      draw_windowskin_toggle(rect, index, @list[index][:symbol])
    else
      ff9_windowskin_win_sysopt_draw_item(index)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Windowskin Toggle                                         [Custom]
  #--------------------------------------------------------------------------
  def draw_windowskin_toggle(rect, index, symbol)
    name = @list[index][:name]
    draw_text(0, rect.y, contents.width / 2, line_height, name, 1)
    
    enabled = $game_system.windowskin_color == :blue
    
    dx = contents.width / 2
    change_color(normal_color, !enabled)
    option1 = YEA::SYSTEM::COMMAND_VOCAB[symbol][1]
    draw_text(dx, rect.y, contents.width / 4, line_height, option1, 1)
    
    dx += contents.width / 4
    change_color(normal_color, enabled)
    option2 = YEA::SYSTEM::COMMAND_VOCAB[symbol][2]
    draw_text(dx, rect.y, contents.width / 4, line_height, option2, 1)
  end
  
  #--------------------------------------------------------------------------
  # * Process Cursor Move                                             [Alias]
  #--------------------------------------------------------------------------
  def cursor_change(direction)
    if current_symbol == :windowskin_color
      change_windowskin_toggle(direction)
    else
      ff9_windowskin_win_sysopt_cursor_change(direction)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Change Windowskin Toggle                                       [Custom]
  #--------------------------------------------------------------------------
  def change_windowskin_toggle(direction)
    value = direction == :left ? false : true
    current_case = $game_system.windowskin_color == :blue
    
    new_color = value ? :blue : :grey
    $game_system.windowskin_color = new_color
    
    Sound.play_cursor if value != current_case
    draw_item(index)
  end
  
end # Window_SystemOptions

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================