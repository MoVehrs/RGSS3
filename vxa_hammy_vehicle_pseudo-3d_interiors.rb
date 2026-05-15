# encoding: utf-8
#==============================================================================
# ▼ Hammy - Vehicle Pseudo-3D × Interiors v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 15.05.2026
# -- Requires: Vehicle Pseudo-3D Database v3.0 by WoodPenguin,
#              Vehicle Pseudo-3D Main Script v3.0.1 by WoodPenguin
# -- Recommended: None
# -- Credits: WoodPenguin (Vehicle Pseudo-3D system), KilloZapit (Cache Back)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_vehicle_pseudo_3d_interiors] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 15.05.2026 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides a vehicle interior navigation system for RPG Maker VX
# Ace. It allows players to enter vehicle interiors such as ship cabins and
# airship holds, with full preservation of vehicle state across the transition.
# 
# The system supports configurable interior map destinations and entry buttons
# per vehicle type, complete position, angle, and altitude preservation during
# interior visits, return travel back to the vehicle from interior maps, and
# nil-safe spriteset handling for compatibility with Cache Back.
# 
# -----------------------------------------------------------------------------
# ► Vehicle Interior Features
# -----------------------------------------------------------------------------
# ★ Configurable interior entry button per vehicle type
# ★ Interior map destination and spawn point configurable per vehicle type
# ★ Full vehicle state preservation across interior entry and return
# ★ Return travel to vehicle from interior maps via script call
# 
# -----------------------------------------------------------------------------
# ► Cache Back Compatibility
# -----------------------------------------------------------------------------
# ★ Nil-safe spriteset handling during Scene_Vehicle map transitions
# ★ Activates automatically when Cache Back's dispose-on-new-map is enabled
# ★ No modifications required to the original Cache Back script
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_Map (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - setup → _wdtk_veh3d_int_gm_setup (only when Cache Back is active)
# 
# -----------------------------------------------------------------------------
# ► Game_Player (Class < Game_Character)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - vehicle_return_state (attr_accessor)
#   - returning_from_interior (attr_accessor)
#   - transferring_to_interior (attr_accessor)
# 
# ★ Alias Methods:
#   - initialize → _wdtk_veh3d_int_gp_initialize
# 
# ★ Overridden Methods:
#   - perform_transfer
#   - get_on_vehicle
#   - on_vehicle_start
#   - on_vehicle_end
# 
# -----------------------------------------------------------------------------
# ► Game_Vehicle (Class < Game_Character)
# -----------------------------------------------------------------------------
# ★ Public Instance Variables:
#   - map_id (attr_reader)
# 
# ★ Alias Methods:
#   - get_off → _wdtk_veh3d_int_gv_get_off
# 
# ★ Overridden Methods:
#   - on_vehicle_start
#   - on_vehicle_end
#   - process_handling
# 
# -----------------------------------------------------------------------------
# ► Sprite_Character (Class < Sprite_Base)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - update_shadow → _wdtk_veh3d_int_sc_update_shadow
# 
# -----------------------------------------------------------------------------
# ► Scene_Map (Class < Scene_Base)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - start → _wdtk_veh3d_int_sm_start
# 
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► Scene_Vehicle (Class < Scene_Map)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - pre_terminate → _wdtk_veh3d_int_sv_pre_terminate
# 
# ★ Overridden Methods:
#   - start
#   - terminate
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following script calls are available for use in events.
# 
# -----------------------------------------------------------------------------
# ► Interior Navigation
# -----------------------------------------------------------------------------
# ★ return_to_vehicle
#   Returns the player to the vehicle from an interior map. Call this from a
#   map event placed on the interior map such as a door or exit point.
#   - No parameters
#   - Returns: nil
# 
# ★ can_return_to_vehicle?
#   Returns true if the player is currently inside a vehicle interior and has
#   a valid vehicle state to return to.
#   - No parameters
#   - Returns: Boolean
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains interior map design requirements and return state
# behavior for correct vehicle interior navigation.
# 
# -----------------------------------------------------------------------------
# ► Interior Map Design
# -----------------------------------------------------------------------------
# An interior can consist of multiple connected maps. Players may move freely
# between them and the return state is preserved throughout. However, none of
# the interior maps may connect to the worldmap. If the player exits to the
# worldmap, the vehicle return state is lost and can_return_to_vehicle? will
# return false, preventing a return to the vehicle scene.
# 
# ★ Interior maps must not be connected to the worldmap.
# ★ Multiple interior maps are supported as long as the worldmap is unreachable.
# ★ The return state persists for the entire duration of the interior visit.
# 
# -----------------------------------------------------------------------------
# ► Return State Behavior
# -----------------------------------------------------------------------------
# The vehicle return state is only set when the player enters the interior
# through the configured entry key. Transferring or teleporting the player
# into an interior map by other means, such as event transfer commands or game
# scripting, will not establish a return state. In that case return_to_vehicle
# has no effect and can_return_to_vehicle? returns false.
# 
# Always guard return_to_vehicle with can_return_to_vehicle? to ensure the
# return option is only presented when a valid return state exists.
# 
# ★ Conditional branch example:
#   can_return_to_vehicle?
#     Script call: return_to_vehicle
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ This script requires WoodPenguin - Vehicle Pseudo-3D Database and must be
#   placed BELOW it.
# 
# ★ This script requires WoodPenguin - Vehicle Pseudo-3D Main Script and must
#   be placed BELOW it.
# 
# ★ If using KilloZapit - Cache Back, place this script BELOW it.
#   Cache Back must be placed ABOVE all Vehicle Pseudo-3D scripts.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

#==============================================================================
# ** Vehicle Pseudo-3D × Interiors Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Vehicle Pseudo-3D × Interiors system.
#==============================================================================

module Hammy
  module Veh3DInteriors
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Interior Map Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the interior map destination for each vehicle type. When the
    # player enters a vehicle interior, they are transferred to this map.
    # 
    # INTERIOR_MAP_IDS: Hash mapping vehicle symbols to interior map IDs
    # 
    # INTERIOR_X_COORDS: Hash mapping vehicle symbols to X coordinates where
    #   the player appears on the interior map
    # 
    # INTERIOR_Y_COORDS: Hash mapping vehicle symbols to Y coordinates where
    #   the player appears on the interior map
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    INTERIOR_MAP_IDS = {
      airship: 2
      # other_vehicle: 5
    }.freeze
    
    INTERIOR_X_COORDS = {
      airship: 8
      # other_vehicle: 10
    }.freeze
    
    INTERIOR_Y_COORDS = {
      airship: 6
      # other_vehicle: 12
    }.freeze
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Interior Entry Button Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the input button used to enter vehicle interiors. The player
    # must press this button while in a vehicle to enter its interior.
    # 
    # INTERIOR_INPUTS: Hash mapping vehicle symbols to input button symbols
    #   Directional: :DOWN :LEFT :RIGHT :UP
    #   Action:      :A :B :C :X :Y :Z :L :R
    #   Keyboard:    :SHIFT :CTRL :ALT
    #   Function:    :F5 :F6 :F7 :F8 :F9
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    INTERIOR_INPUTS = {
      airship: :X
      # other_vehicle: :A
    }.freeze
    
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
    # * Load Config
    #------------------------------------------------------------------------
    def self.load_config
      data = WdTk::Veh3D.data
      data.each do |vehicle, _|
        if INTERIOR_MAP_IDS.key?(vehicle)
          data[vehicle][:interior_map_id] = INTERIOR_MAP_IDS[vehicle]
          data[vehicle][:interior_x] = INTERIOR_X_COORDS[vehicle]
          data[vehicle][:interior_y] = INTERIOR_Y_COORDS[vehicle]
          data[vehicle][:inp_interior] = INTERIOR_INPUTS[vehicle]
        end
      end
    end
    
  end # Veh3DInteriors
end # Hammy

Hammy::Veh3DInteriors.load_config

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_accessor :vehicle_return_state
  attr_accessor :returning_from_interior
  attr_accessor :transferring_to_interior
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_int_gp_initialize, :initialize unless $@
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #--------------------------------------------------------------------------
  def initialize
    _wdtk_veh3d_int_gp_initialize
    
    @vehicle_return_state = nil
    @returning_from_interior = false
    @transferring_to_interior = false
  end
  
  #--------------------------------------------------------------------------
  # * Clear Vehicle Interior Return State                            [Custom]
  #--------------------------------------------------------------------------
  def clear_vehicle_return_state
    @vehicle_return_state = nil
    @returning_from_interior = false
    @transferring_to_interior = false
  end
  
  #--------------------------------------------------------------------------
  # * Check If Can Return To Vehicle From Interior                   [Custom]
  #--------------------------------------------------------------------------
  def can_return_to_vehicle?
    !@vehicle_return_state.nil?
  end
  
  #--------------------------------------------------------------------------
  # * Enter Vehicle Interior                                         [Custom]
  #--------------------------------------------------------------------------
  def enter_vehicle_interior
    return false unless vehicle && vehicle.has_interior?
    
    veh = vehicle
    vbgm = veh.system_vehicle.bgm
    
    @vehicle_return_state = {
      vehicle_type: @vehicle_type,
      map_id: $game_map.map_id,
      x: veh.x.round,
      y: veh.y.round,
      angle: veh.angle,
      altitude: veh.altitude,
      interior_has_bgm: false,
      vehicle_bgm: vbgm,
      vehicle_bgm_pos: Audio.bgm_pos
    }
    
    @returning_from_interior = false
    @transferring_to_interior = true
    veh.get_off_to_interior
    
    @in_vehicle = false
    @transparent = false
    @vehicle_getting_off = false
    
    reserve_transfer(veh.interior_map_id, veh.interior_x, veh.interior_y)
    @vehicle_type = :walk
    
    veh.get_off
    SceneManager.goto(Scene_Map)
    true
  end
  
  #--------------------------------------------------------------------------
  # * Return From Interior                                           [Custom]
  #--------------------------------------------------------------------------
  def return_from_interior
    return false unless can_return_to_vehicle?
    
    state = @vehicle_return_state
    @returning_from_interior = true
    
    reserve_transfer(state[:map_id], state[:x], state[:y])
    SceneManager.goto(Scene_Vehicle)
    true
  end
  
  #--------------------------------------------------------------------------
  # * Execute Location Transfer                                  [Overridden]
  #--------------------------------------------------------------------------
  def perform_transfer
    if transfer? && vehicle && @in_vehicle
      vehicle.set_direction(@new_direction)
      _wdtk_veh3d_perform_transfer
      vehicle.sync_with_player
    else
      if @returning_from_interior
        if @new_map_id != $game_map.map_id
          $game_map.setup(@new_map_id)
        end
        
        moveto(@new_x, @new_y)
        clear_transfer_info
      else
        _wdtk_veh3d_perform_transfer
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Board Vehicle                                              [Overridden]
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.round_x_with_direction(@x, @direction)
    front_y = $game_map.round_y_with_direction(@y, @direction)
    
    $game_map.vehicles.each do |veh|
      next if veh.control
      
      if veh.get_here?
        @vehicle_type = veh.type if veh.pos?(@x, @y)
      else
        @vehicle_type = veh.type if veh.pos?(front_x, front_y)
      end
    end
    
    if vehicle
      @vehicle_getting_on = true
      force_move_forward unless vehicle.get_here?
      @followers.gather
      
      clear_vehicle_return_state
      @transferring_to_interior = false
    end
    
    @vehicle_getting_on
  end
  
  #--------------------------------------------------------------------------
  # * Vehicle Start Processing                                   [Overridden]
  #--------------------------------------------------------------------------
  def on_vehicle_start
    @in_vehicle = true
    
    if @returning_from_interior && vehicle
      vehicle.instance_variable_set(:@interior_transfer, false)
      vehicle.refresh
      @returning_from_interior = false
    end
    
    if @vehicle_type == :walk
      @vehicle_type = @keep_vehicles.pop
      @transparent = true
      @followers.update
    end
    
    _wdtk_veh3d_perform_transfer
    vehicle.on_vehicle_start
  end
  
  #--------------------------------------------------------------------------
  # * Vehicle End Processing                                     [Overridden]
  #--------------------------------------------------------------------------
  def on_vehicle_end
    @in_vehicle = false
    center(@x, @y)
    
    if vehicle
      vehicle.on_vehicle_end
      
      if @keep_vehicles.include?(@vehicle_type)
        vehicle.get_off
        @vehicle_type = :walk
        @transparent = false
        @followers.update
      elsif !vehicle.get_here?
        force_move_forward
        @transparent = false
      end
    end
    
    unless $game_player.transferring_to_interior
      $game_map.autoplay
    end
    
    _wdtk_veh3d_perform_transfer
  end
  
end # Game_Player

#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates are set to (-1,-1).
#==============================================================================

class Game_Vehicle
  #--------------------------------------------------------------------------
  # * Public Instance Variables                                      [Custom]
  #--------------------------------------------------------------------------
  attr_reader :map_id
  
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_int_gv_get_off, :get_off unless $@
  
  #--------------------------------------------------------------------------
  # * Interior Map ID                                                [Custom]
  #--------------------------------------------------------------------------
  def interior_map_id
    param(:interior_map_id) || 0
  end
  
  #--------------------------------------------------------------------------
  # * Interior Map X Coordinate                                      [Custom]
  #--------------------------------------------------------------------------
  def interior_x
    param(:interior_x) || 0
  end
  
  #--------------------------------------------------------------------------
  # * Interior Map Y Coordinate                                      [Custom]
  #--------------------------------------------------------------------------
  def interior_y
    param(:interior_y) || 0
  end
  
  #--------------------------------------------------------------------------
  # * Interior Input Button                                          [Custom]
  #--------------------------------------------------------------------------
  def inp_interior
    param(:inp_interior) || :X
  end
  
  #--------------------------------------------------------------------------
  # * Check If Has Interior Configured                               [Custom]
  #--------------------------------------------------------------------------
  def has_interior?
    interior_map_id > 0 && interior_x >= 0 && interior_y >= 0
  end
  
  #--------------------------------------------------------------------------
  # * Get Off To Interior                                            [Custom]
  #--------------------------------------------------------------------------
  def get_off_to_interior
    @interior_transfer = true
  end
  
  #--------------------------------------------------------------------------
  # * Restore From Interior                                          [Custom]
  #--------------------------------------------------------------------------
  def restore_from_interior(state)
    @interior_transfer = false
    @driving  = true
    
    @x = @real_x = state[:x]
    @y = @real_y = state[:y]
    @angle = state[:angle]
    @altitude = state[:altitude]
    
    moveto(@x.round, @y.round)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Get Off Vehicle                                                 [Alias]
  #--------------------------------------------------------------------------
  def get_off
    if @interior_transfer
      @driving = false
      @walk_anime = false
      @direction = 4
      @step_anime = param(:step_anime) != false
      
      SceneManager.goto(Scene_Map)
    else
      _wdtk_veh3d_int_gv_get_off
    end
  end
  
  #--------------------------------------------------------------------------
  # * Vehicle Start Processing                                   [Overridden]
  #--------------------------------------------------------------------------
  def on_vehicle_start
    unless @control
      @control = true
      
      if flight? && !@interior_transfer
        @altitude = [[@altitude, max_altitude].min, min_altitude].max
      elsif !flight?
        @altitude = 8
      end
    end
    
    $game_switches[param(:switch_id)] = true if param(:switch_id)
  end

  #--------------------------------------------------------------------------
  # * Vehicle End Processing                                     [Overridden]
  #--------------------------------------------------------------------------
  def on_vehicle_end
    unless @driving
      @control = false
      
      unless @interior_transfer
        @altitude = flight? ? 32 : 0
      end
      
      moveto(@x.round, @y.round)
    end
    
    $game_switches[param(:switch_id)] = false if param(:switch_id)
    refresh
  end

  #--------------------------------------------------------------------------
  # * Non-Control Processing                                     [Overridden]
  #--------------------------------------------------------------------------
  def process_handling
    if @drive_speed <= 12
      if Input.trigger?(param(:inp_get_off)) || (!param(:inp_get_off) &&
         @altitude <= (min_altitude + 8) && Input.press?(param(:inp_down)))
        return stop if $game_player.get_off_vehicle
      end
      
      if Input.trigger?(param(:inp_event))
        $game_player.set_direction(angle_dir)
        return stop if $game_player.check_action_event
      end
    end
    
    if Input.trigger?(param(:inp_menu))
      return process_menu
    end
    
    if has_interior?
      if Input.trigger?(inp_interior)
        return stop if $game_player.enter_vehicle_interior
      end
    end
  end
  
end # Game_Vehicle

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Return To Vehicle                                              [Custom]
  #--------------------------------------------------------------------------
  def return_to_vehicle
    $game_player.return_from_interior
  end
  
  #--------------------------------------------------------------------------
  # * Can Return To Vehicle                                          [Custom]
  #--------------------------------------------------------------------------
  def can_return_to_vehicle?
    $game_player.can_return_to_vehicle?
  end
  
end # Game_Interpreter

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_int_sc_update_shadow, :update_shadow unless $@
  
  #--------------------------------------------------------------------------
  # * Update Shadow                                                   [Alias]
  #--------------------------------------------------------------------------
  def update_shadow
    return unless @character.is_a?(Game_Vehicle)
    
    if @character.map_id != $game_map.map_id
      dispose_shadow
      return
    end
    
    _wdtk_veh3d_int_sc_update_shadow
  end
  
end # Sprite_Character

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_int_sm_start, :start unless $@
  
  #--------------------------------------------------------------------------
  # * Start Processing                                                [Alias]
  #--------------------------------------------------------------------------
  def start
    _wdtk_veh3d_int_sm_start
    
    if $game_player.transferring_to_interior
      $game_player.transferring_to_interior = false
      $game_player.perform_transfer if $game_player.transfer?
      
      if $game_player.vehicle_return_state
        interior_has_bgm = $game_map.instance_variable_get(:@map).autoplay_bgm
        $game_player.vehicle_return_state[:interior_has_bgm] = interior_has_bgm
        
        if interior_has_bgm
          $game_map.autoplay
        end
      end
    end
  end
  
end # Scene_Map

#==============================================================================
# ** Scene_Vehicle
#------------------------------------------------------------------------------
#  This class handles the vehicle interior screen. It inherits from Scene_Map
# and modifies the basic update cycle for pause system compatibility.
#==============================================================================

class Scene_Vehicle < Scene_Map
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_int_sv_pre_terminate, :pre_terminate unless $@
  
  #--------------------------------------------------------------------------
  # * Pre-Termination Processing                                      [Alias]
  #--------------------------------------------------------------------------
  def pre_terminate
    if $game_player.transferring_to_interior &&
      $game_player.vehicle_return_state
       state = $game_player.vehicle_return_state
       veh = $game_map.vehicle(state[:vehicle_type])
       
       $game_player.in_vehicle = true
       $game_player.instance_variable_set(:@vehicle_type, state[:vehicle_type])
       
       veh.instance_variable_set(:@driving, true) if veh
       @spriteset.update
       _wdtk_veh3d_int_sv_pre_terminate
       
       $game_player.in_vehicle = false
       $game_player.instance_variable_set(:@vehicle_type, :walk)
       
       veh.instance_variable_set(:@driving, false) if veh
    else
      _wdtk_veh3d_int_sv_pre_terminate
    end
  end
  
  #--------------------------------------------------------------------------
  # * Start Processing                                           [Overridden]
  #--------------------------------------------------------------------------
  def start
    WdTk::Veh3D.reset
    
    if $game_player.returning_from_interior &&
       $game_player.vehicle_return_state
      state = $game_player.vehicle_return_state
      $game_player.perform_transfer if $game_player.transfer?
      
      veh = $game_map.vehicle(state[:vehicle_type])
      if veh
        veh.restore_from_interior(state)
        veh.instance_variable_set(:@driving, true)
        veh.instance_variable_set(:@control, true)
        
        $game_player.in_vehicle = true
        $game_player.instance_variable_set(:@transparent, true)
        $game_player.instance_variable_set(:@vehicle_type, state[:vehicle_type])
        
        $game_player.vehicle_return_state = nil
        $game_player.returning_from_interior = false
        
        if state[:interior_has_bgm]
          vbgm = veh.system_vehicle.bgm
          vbgm.play(0) if vbgm
        end
      end
    end
    
    $game_player.on_vehicle_start
    super
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing                                     [Overridden]
  #--------------------------------------------------------------------------
  def terminate
    if SceneManager.scene_is?(Scene_Map) &&
       !$game_player.transferring_to_interior
      $game_player.on_vehicle_end
    end
    
    super
    GC.start
  end
  
end # Scene_Vehicle

if defined?(Cache::DISPOSE_ON_NEWMAP) && Cache::DISPOSE_ON_NEWMAP
  #============================================================================
  # ** Game_Map
  #----------------------------------------------------------------------------
  #  This class handles maps. It includes scrolling and passage determination
  # functions. The instance of this class is referenced by $game_map.
  #============================================================================
  
  class Game_Map
    #------------------------------------------------------------------------
    # * Alias Method Definitions                                     [Custom]
    #------------------------------------------------------------------------
    alias_method :_wdtk_veh3d_int_gm_setup, :setup unless $@
    
    #------------------------------------------------------------------------
    # * Setup                                                         [Alias]
    #------------------------------------------------------------------------
    def setup(map_id)
      if SceneManager.scene.is_a?(Scene_Vehicle)
        begin
          cache_setup_base(map_id)
        rescue NoMethodError
          _wdtk_veh3d_int_gm_setup(map_id)
        end
      elsif SceneManager.scene.is_a?(Scene_Map)
        if SceneManager.scene.instance_variable_get(:@spriteset)
          _wdtk_veh3d_int_gm_setup(map_id)
        else
          begin
            cache_setup_base(map_id)
          rescue NoMethodError
            _wdtk_veh3d_int_gm_setup(map_id)
          end
        end
      else
        _wdtk_veh3d_int_gm_setup(map_id)
      end
    end
    
  end # Game_Map
end # Cache Back Guard

#==============================================================================
#
# ▼ End of File
#
#==============================================================================
