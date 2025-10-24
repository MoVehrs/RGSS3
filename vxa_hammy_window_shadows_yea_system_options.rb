#==============================================================================
# ▼ Hammy - Window Shadows - YEA System Options Addon v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 23.10.2025
# -- Requires: Hammy Window Shadows v1.00 or higher,
#              YEA-SystemOptions v1.00
# -- Optional: Theolized - Global System Option v1.00
# -- Credits: Yanfly (YEA-SystemOptions, Documentation style),
#             Theo Allen (Global System Option)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_window_shadows_system_options] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 23.10.2025 - Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This addon extends the Yanfly System Options script to include window shadow
# enable/disable functionality for the Hammy Window Shadows System. It
# provides seamless integration with the system options menu, allowing players
# to toggle window shadows directly from the game's options screen.
# 
# The addon automatically detects whether Theo's Global System Option script is
# present and adapts its save behavior accordingly, supporting both standard
# save file storage and global options storage.
# 
# -----------------------------------------------------------------------------
# ► Core Integration Features
# -----------------------------------------------------------------------------
# ★ Window shadows toggle command in System Options menu
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
#   - window_shadows (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → window_shadows_optiondata_initialize
# 
# -----------------------------------------------------------------------------
# ► Window_SystemOptions (Class < Window_Command)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - draw_item → window_shadows_win_sysopt_draw_item
#   - cursor_change → window_shadows_win_sysopt_cursor_change
#   - make_command_list → window_shadows_win_sysopt_make_comm_list
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ Place this script BELOW YEA-SystemOptions and Hammy Window Shadows.
# 
# ★ If using Theolized Global System Option v1.0, window shadow preferences
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
# ** Window Shadows Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Window Shadows system.
#==============================================================================

module CONFIG
  module WINDOW_SHADOWS
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - System Options Anchor -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the insertion position for the window shadows command in the
    # System Options menu. The command will be inserted after the specified
    # anchor command.
    # 
    # WINDOW_SHADOWS_INSERT_ANCHOR: Symbol of the anchor command
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOW_SHADOWS_INSERT_ANCHOR = :window_blu
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Command Vocabulary -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the display text and help information for the window shadows
    # toggle command in the System Options menu.
    # 
    # WINDOW_SHADOWS_VOCAB: Hash containing command text and help description
    #   [0] = Command name, [1] = Off text, [2] = On text, [3] = Help text
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    WINDOW_SHADOWS_VOCAB = {
      :window_shadows => ["Window Shadows", "Off", "On",
                          "Enable or disable window shadows.\n" \
                          "Shadows add visual depth to windows."
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
    # * Merge Window Shadows Vocabulary                                [Custom]
    #--------------------------------------------------------------------------
    if $imported["YEA-SystemOptions"]
      YEA::SYSTEM::COMMAND_VOCAB.merge!(WINDOW_SHADOWS_VOCAB)
    end
    
  end # CONFIG::WINDOW_SHADOWS
end # CONFIG

#==============================================================================
# ▼ Script Dependencies Check
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section checks for the presence of required companion scripts.
# If any required scripts are missing, it displays an error message and exits.
#==============================================================================

unless $imported["YEA-SystemOptions"]
  msgbox("YEA-SystemOptions v1.00 by Yanfly is required but not found!\n" \
         "Please install the required script before using " \
         "Window Shadows - System Options Addon.")
  exit
end

unless $imported[:hammy_window_shadows]
  msgbox("Hammy Window Shadows v1.00 is required but not found!\n" \
         "Please install the required script before using " \
         "Window Shadows - System Options Addon.")
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
    attr_accessor :window_shadows
    
    #--------------------------------------------------------------------------
    # * Alias Method Definitions                                       [Custom]
    #--------------------------------------------------------------------------
    alias_method :window_shadows_optiondata_initialize, :initialize
    
    #--------------------------------------------------------------------------
    # * Object Initialization                                           [Alias]
    #--------------------------------------------------------------------------
    def initialize
      window_shadows_optiondata_initialize
      @window_shadows = true
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
  # * Get Window Shadows Setting                                     [Custom]
  #--------------------------------------------------------------------------
  def window_shadows
    if $imported[:Theo_GlobalOption]
      return $option_data.window_shadows
    else
      return @window_shadows
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Window Shadows Setting                                    [Custom]
  #--------------------------------------------------------------------------
  def window_shadows=(value)
    if $imported[:Theo_GlobalOption]
      $option_data.window_shadows = value
      OptionData.save
    else
      @window_shadows = value
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
  alias_method :window_shadows_win_sysopt_draw_item, :draw_item
  alias_method :window_shadows_win_sysopt_cursor_change, :cursor_change
  alias_method :window_shadows_win_sysopt_make_comm_list, :make_command_list
  
  #--------------------------------------------------------------------------
  # * Create Command List                                             [Alias]
  #--------------------------------------------------------------------------
  def make_command_list
    window_shadows_win_sysopt_make_comm_list
    inject_window_shadows_command
  end
  
  #--------------------------------------------------------------------------
  # * Inject Window Shadows Command                                  [Custom]
  #--------------------------------------------------------------------------
  def inject_window_shadows_command
    anchor_index = @list.find_index { |item| 
      item[:symbol] == CONFIG::WINDOW_SHADOWS::WINDOW_SHADOWS_INSERT_ANCHOR 
    }
    
    if anchor_index
      insert_index = anchor_index + 1
    else
      insert_index = @list.size
    end
    
    vocab = YEA::SYSTEM::COMMAND_VOCAB
    
    window_shadows_command = {
      :name => vocab[:window_shadows][0],
      :symbol => :window_shadows,
      :enabled => true,
      :ext => nil
    }
    
    @list.insert(insert_index, window_shadows_command)
    @help_descriptions[:window_shadows] = vocab[:window_shadows][3]
  end
  
  #--------------------------------------------------------------------------
  # * Draw Item                                                       [Alias]
  #--------------------------------------------------------------------------
  def draw_item(index)
    if @list[index][:symbol] == :window_shadows
      reset_font_settings
      rect = item_rect(index)
      contents.clear_rect(rect)
      draw_window_shadows_toggle(rect, index, @list[index][:symbol])
    else
      window_shadows_win_sysopt_draw_item(index)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Draw Window Shadows Toggle                                     [Custom]
  #--------------------------------------------------------------------------
  def draw_window_shadows_toggle(rect, index, symbol)
    name = @list[index][:name]
    draw_text(0, rect.y, contents.width / 2, line_height, name, 1)
    
    enabled = $game_system.window_shadows
    
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
    if current_symbol == :window_shadows
      change_window_shadows_toggle(direction)
    else
      window_shadows_win_sysopt_cursor_change(direction)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Change Window Shadows Toggle                                   [Custom]
  #--------------------------------------------------------------------------
  def change_window_shadows_toggle(direction)
    value = direction == :left ? false : true
    current_case = $game_system.window_shadows
    
    $game_system.window_shadows = value
    
    Sound.play_cursor if value != current_case
    draw_item(index)
  end
  
end # Window_SystemOptions

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================