# encoding: utf-8
#==============================================================================
# ▼ Hammy - Simple Map Display × Performance Enhancements v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: Simple Map Display v2.4 by WoodPenguin
# -- Optional: Vehicle Pseudo-3D Database v3.0 by WoodPenguin,
#              Vehicle Pseudo-3D Main Script v3.0.1 by WoodPenguin
# -- Recommended: None
# -- Credits: WoodPenguin (Simple Map Display system)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_simple_map_display_performance] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 25.05.2026 - (v1.01) Applied new documentation conventions.
# 
# 17.05.2026 - (v1.00) Initial release.
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This performance optimization addon enhances WoodPenguin's Simple Map Display
# script with a pre-computation strategy for marker rotation in RPG Maker VX
# Ace. It reduces redundant trigonometric calculations when the map rotation
# flag is active during vehicle travel.
# 
# The optimizations include rotation matrix pre-computation for the Type 3
# circular minimap, sin and cos calculated once per frame and shared across
# all visible markers, and an identical visual result to the original
# implementation at significantly reduced per-frame cost.
# 
# -----------------------------------------------------------------------------
# ► Performance Enhancement Features
# -----------------------------------------------------------------------------
# ★ Rotation matrix pre-computation for Type 3 marker rotation
# ★ sin/cos calculated once per update instead of once per visible marker
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► Spriteset_SimpleMap (Class < Spriteset_Base)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update_marker_t3
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ This script requires WoodPenguin - Simple Map Display and must be placed
#   BELOW it.
# 
# ★ If using WoodPenguin - Vehicle Pseudo-3D Database, place this script BELOW
#   it.
# 
# ★ If using WoodPenguin - Vehicle Pseudo-3D Main Script, place this script
#   BELOW it.
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
# ** Spriteset_SimpleMap
#------------------------------------------------------------------------------
#  This spriteset handles the simple map overlay display. It is created and
# managed within the Spriteset_Map class.
#==============================================================================

class Spriteset_SimpleMap
  #--------------------------------------------------------------------------
  # * Update Marker (Type 3)                                     [Overridden]
  #--------------------------------------------------------------------------
  def update_marker_t3(player)
    @marker_sprite.opacity = 320 - @update_count * 4
    
    bitmap = @marker_sprite.bitmap
    bitmap.clear
    
    x_rate = @map_width / $game_map.width * @zoom
    y_rate = @map_height / $game_map.height * @zoom
    
    psx = $game_map.adjust_x(player.real_x)
    psy = $game_map.adjust_y(player.real_y)
    
    cx = bitmap.width / 2
    cy = bitmap.height / 2
    
    if turn_map?
      radian = -player.angle * Math::PI / 180
      sin_r = Math.sin(radian)
      cos_r = Math.cos(radian)
    else
      radian = 0
    end
    
    all_events.each do |event|
      m = event.marker
      next unless m
      
      dx = (($game_map.adjust_x(event.real_x) - psx) * x_rate).to_i
      dy = (($game_map.adjust_y(event.real_y) - psy) * y_rate).to_i
      
      next unless dy.between?(-(cy - 1), (cy - 1))
      
      n = Math.sqrt(cy**2 - dy**2) * cx / cy - 1
      next unless dx.between?(-n, n)
      
      if m.is_a?(Integer)
        @marker_bitmaps[m] ||=
          make_marker(get_color(m), WdTk::SimpMap::Radius)
        marker = @marker_bitmaps[m]
      else
        marker = Cache.load_bitmap(WdTk::SimpMap::DirName, m)
      end
      
      if radian != 0 && (dx != 0 || dy != 0)
        new_dx =  dx * cos_r + dy * sin_r
        new_dy = -dx * sin_r + dy * cos_r
        
        dx = new_dx.to_i
        dy = new_dy.to_i
      end
      
      mx = cx + dx - marker.width / 2
      my = cy + dy - marker.height / 2
      
      bitmap.blt(mx, my, marker, marker.rect)
    end
  end
  
end # Spriteset_SimpleMap

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
