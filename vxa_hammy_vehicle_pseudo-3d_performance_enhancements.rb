# encoding: utf-8
#==============================================================================
# ▼ Hammy - Vehicle Pseudo-3D × Performance Enhancements v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: Vehicle Pseudo-3D Database v3.0 by WoodPenguin,
#              Vehicle Pseudo-3D Main Script v3.0.1 by WoodPenguin
# -- Optional: Vehicle Pseudo-3D OP1 v2.1 by WoodPenguin,
#              Vehicle Pseudo-3D OP2 v2.1 by WoodPenguin,
#              Vehicle Pseudo-3D OP4 v2.1 by WoodPenguin
# -- Recommended: None
# -- Credits: WoodPenguin (Vehicle Pseudo-3D system)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_vehicle_pseudo_3d_performance] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 25.05.2026 - (v1.01) Applied new documentation conventions.
# 
# 15.05.2026 - (v1.00) Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This performance optimization addon enhances WoodPenguin's Vehicle Pseudo-3D
# system with intelligent caching and pre-computation strategies. It reduces
# redundant calculations for vehicle angles, view distances, and event
# positioning while maintaining full compatibility with all Vehicle Pseudo-3D
# optional modules.
# 
# The optimizations include result caching for angle calculations, class-level
# caching for view distances, and optional enhancements for OP1 Compass,
# OP2 Field of View, and OP4 Event 3D modules when present.
# 
# -----------------------------------------------------------------------------
# ► Performance Enhancement Features
# -----------------------------------------------------------------------------
# ★ Angle radian result caching with change detection
# ★ Event radian caching for WoodPenguin's Event 3D Display addon
# ★ Trigonometric pre-computation for WoodPenguin's Compass addon
# ★ Optimized map snapshot tiling loop for WoodPenguin's Field of View addon
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Game_Vehicle (Class < Game_Character)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - initialize → _wdtk_veh3d_pe_gv_initialize
# 
# ★ Overridden Methods:
#   - angle_radian
#   - view_distance
#   - event_radian (if OP4 present)
# 
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► Sprite_Compass (Class < Sprite)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update
# 
# -----------------------------------------------------------------------------
# ► WdTk::Veh3D::OP2 (Module)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - snap_map
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
# ★ If using WoodPenguin - Vehicle Pseudo-3D OP1, place this script BELOW OP1.
# 
# ★ If using WoodPenguin - Vehicle Pseudo-3D OP2, place this script BELOW OP2.
# 
# ★ If using WoodPenguin - Vehicle Pseudo-3D OP4, place this script BELOW OP4.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
#==============================================================================

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
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates are set to (-1,-1).
#==============================================================================

class Game_Vehicle
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_pe_gv_initialize, :initialize unless $@
  
  #--------------------------------------------------------------------------
  # * Class Variables                                                [Custom]
  #--------------------------------------------------------------------------
  @@cached_view_distance = nil
  @@last_graphics_height = nil
  
  #--------------------------------------------------------------------------
  # * Object Initialization                                           [Alias]
  #     type : vehicle type (:boat, :ship, :airship)
  #--------------------------------------------------------------------------
  def initialize(type)
    _wdtk_veh3d_pe_gv_initialize(type)
    
    @cached_angle_radian = 0.0
    @last_angle = -1
    @cached_event_radian = 0.0
    @last_event_angle = -1
  end
  
  #--------------------------------------------------------------------------
  # * Get Radian from Angle                                      [Overridden]
  #--------------------------------------------------------------------------
  def angle_radian
    return @cached_angle_radian if @angle == @last_angle
    @last_angle = @angle
    
    if @angle < 90
      sx = [@angle, 45].min
    elsif @angle < 270
      sx = [[180 - @angle, 45].min, -45].max
    else
      sx = [@angle - 360, -45].max
    end
    
    sy = [[(@angle - 180).abs - 90, 45].min, -45].max
    base = @angle * PI / 180
    @cached_angle_radian = base + (atan2(sx, sy) - base) * 2
  end
  
  #--------------------------------------------------------------------------
  # * Get View Distance                                          [Overridden]
  #--------------------------------------------------------------------------
  def view_distance
    if @@cached_view_distance.nil? || @@last_graphics_height != Graphics.height
      @@last_graphics_height = Graphics.height
      @@cached_view_distance = 5.8 + (Graphics.height - 416) / 64.0
    end
    
    @@cached_view_distance
  end
  
end # Game_Vehicle

if WdTk.include?(:Veh3D_OP1)
  #============================================================================
  # ** Sprite_Compass
  #----------------------------------------------------------------------------
  #  This sprite displays a compass indicating vehicle orientation. It shows
  # directional indicators and is used within the Spriteset_Vehicle class.
  #============================================================================
  
  class Sprite_Compass
    #------------------------------------------------------------------------
    # * Frame Update                                             [Overridden]
    #------------------------------------------------------------------------
    def update
      ox = Compass_W / 2
      oy = Compass_H / 2
      oy = oy * (@vehicle.altitude + 100) / 200 if @vehicle.flight?
      
      base_rad = @vehicle.angle * Math::PI / 180
      sin_base = Math.sin(base_rad)
      cos_base = Math.cos(base_rad)
      @dir_sprites.each_with_index do |sprite, i|
        case i
        when 0
          sin_a = sin_base
          cos_a = cos_base
        when 1
          sin_a = cos_base
          cos_a = -sin_base
        when 2
          sin_a = -sin_base
          cos_a = -cos_base
        when 3
          sin_a = -cos_base
          cos_a = sin_base
        end
        sprite.x = self.x + ox * sin_a
        sprite.y = self.y - oy * cos_a
      end
      
      if DrawPos != 0 && Graphics.frame_count % 3 == 0
        @pos_sprite.bitmap.clear
        
        if PosBack == 1
          rect = @pos_sprite.bitmap.rect
          rect.width /= 2
          @pos_sprite.bitmap.gradient_fill_rect(rect, BackColor2, BackColor1)
          rect.x += rect.width
          @pos_sprite.bitmap.gradient_fill_rect(rect, BackColor1, BackColor2)
        end
        
        @pos_sprite.bitmap.draw_text(0, -1, @pos_sprite.width, 20, pos_text, 1)
      end
    end
    
  end # Sprite_Compass
end # Veh3D_OP1 Guard

if WdTk.include?(:Veh3D_OP2)
  #============================================================================
  # ** WdTk::Veh3D::OP2
  #----------------------------------------------------------------------------
  #  This module handles the Field of View Extension for the Vehicle Pseudo-3D
  # system. It manages extended viewing distances, map bitmap caching, and
  # padding for vehicle snapshot rendering.
  #============================================================================
  
  module WdTk::Veh3D::OP2
    #------------------------------------------------------------------------
    # * Create Map Snapshot                                      [Overridden]
    #     spriteset : parent spriteset instance
    #------------------------------------------------------------------------
    def self.snap_map(spriteset)
      w = $game_map.width * 32
      h = $game_map.height * 32
      pad = @@padding
      
      gw = Graphics.width
      gh = Graphics.height
      x_tiles = (w + gw - 1) / gw
      y_tiles = (h + gh - 1) / gh
      bitmap = Bitmap.new(w + pad * 2, h + pad * 2)
      
      x_tiles.times do |xi|
        x = xi * gw
        y_tiles.times do |yi|
          y = yi * gh
          $game_map.set_pos(x / 32.0, y / 32.0)
          spriteset.refresh_tilemap
          snap = Graphics.snap_to_bitmap
          bitmap.blt(x + pad, y + pad, snap, snap.rect)
          snap.dispose
        end
      end
      
      bitmap.blt(pad, 0, bitmap, Rect.new(pad, h, w, pad))
      bitmap.blt(pad, pad + h, bitmap, Rect.new(pad, pad, w, pad))
      bitmap.blt(0, 0, bitmap, Rect.new(w, 0, pad, h + pad * 2))
      bitmap.blt(pad + w, 0, bitmap, Rect.new(pad, 0, pad, h + pad * 2))
      bitmap
    end
    
  end # WdTk::Veh3D::OP2
end # Veh3D_OP2 Guard

if WdTk.include?(:Veh3D_OP4)
  #============================================================================
  # ** Game_Vehicle
  #----------------------------------------------------------------------------
  #  This class handles vehicles. It's used within the Game_Map class. If there
  # are no vehicles on the current map, the coordinates are set to (-1,-1).
  #============================================================================
  
  class Game_Vehicle
    #------------------------------------------------------------------------
    # * Get Event Radian                                         [Overridden]
    #------------------------------------------------------------------------
    def event_radian
      return @cached_event_radian if @last_event_angle == @angle
      @last_event_angle = @angle
      
      if @angle < 90
        sx = @angle / 90.0
      elsif @angle < 270
        sx = (180 - @angle) / 90.0
      else
        sx = (@angle - 360) / 90.0
      end
      
      sy = ((@angle - 180).abs - 90) / 90.0
      base = @angle / 180 * PI
      @cached_event_radian = base + (atan2(sx, sy) - base) * 2
    end
    
  end # Game_Vehicle
end # Veh3D_OP4 Guard

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
