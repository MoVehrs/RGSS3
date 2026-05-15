# encoding: utf-8
#==============================================================================
# ▼ Hammy - Vehicle Pseudo-3D × Widescreen Resolution v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 15.05.2026
# -- Requires: Vehicle Pseudo-3D Database v3.0 by WoodPenguin,
#              Vehicle Pseudo-3D Main Script v3.0.1 by WoodPenguin,
#              Vehicle Pseudo-3D OP2 v2.1 by WoodPenguin
# -- Optional: Vehicle Pseudo-3D OP3 v1.0 by WoodPenguin
# -- Recommended: None
# -- Credits: WoodPenguin (Vehicle Pseudo-3D system)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_vehicle_pseudo_3d_widescreen] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 15.05.2026 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script eliminates tilemap cutoff bands at the left and right screen
# borders when riding a vehicle at widescreen resolutions in WoodPenguin's
# Vehicle Pseudo-3D system. It replaces the default snapshot square with a
# larger, vehicle-centered square that provides full screen coverage at
# every rotation angle.
# 
# The system supports automatic padding calculation, vehicle-centered snapshot
# positioning, symmetric diamond-shaped coverage at all rotation angles, and
# full compatibility with OP2 Field of View Extension and OP3 Map Zoom.
# 
# -----------------------------------------------------------------------------
# ► Core Widescreen Features
# -----------------------------------------------------------------------------
# ★ Elimination of left and right edge tilemap cutoff bands
# ★ Vehicle-centered snapshot positioning for symmetric coverage
# ★ Full screen width coverage at every vehicle rotation angle
# ★ Automatic compatibility with OP2 Field of View Extension
# ★ Optional compatibility with OP3 Map Zoom configurations
# ★ Dynamic padding adjustment via OP2 padding writer interface
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► DataManager (Module/Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - init → _wdtk_veh3d_ws_init
# 
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► WdTk::Veh3D::OP2 (Module)
# -----------------------------------------------------------------------------
# ★ Added Setters:
#   - padding=
# 
# -----------------------------------------------------------------------------
# ► Spriteset_Vehicle (Class < Spriteset_Map)
# -----------------------------------------------------------------------------
# ★ Alias Methods:
#   - update_snap → _wdtk_veh3d_ws_update_snap
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
# ★ This script requires WoodPenguin - Vehicle Pseudo-3D OP2 and must be placed
#   BELOW it.
# 
# ★ If using WoodPenguin - Vehicle Pseudo-3D OP3, place this script BELOW the
#   OP3 script.
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
# ** WdTk::Veh3D::OP2
#------------------------------------------------------------------------------
#  This module handles the Field of View Extension for the Vehicle Pseudo-3D
# system. It manages extended viewing distances, map bitmap caching, and
# padding for vehicle snapshot rendering.
#==============================================================================

module WdTk::Veh3D::OP2
  #--------------------------------------------------------------------------
  # * Set Padding                                                    [Custom]
  #--------------------------------------------------------------------------
  def self.padding=(val)
    @@padding = val
  end
  
end # WdTk::Veh3D::OP2

#==============================================================================
# ** WdTk::Veh3D::WS
#------------------------------------------------------------------------------
#  This module handles the widescreen fix for the Vehicle Pseudo-3D system.
# It calculates and ensures sufficient padding for vehicle snapshot rendering
# at widescreen resolutions.
#==============================================================================

module WdTk::Veh3D::WS
  #--------------------------------------------------------------------------
  # * Ensure Padding                                                 [Custom]
  #--------------------------------------------------------------------------
  def self.ensure_padding
    return unless WdTk.include?(:Veh3D_OP2)
    
    mzoom = WdTk.include?(:Veh3D_OP3) ? WdTk::Veh3D::OP3::MapZoom : 1.0
    max_vzoom = WdTk::Veh3D.max_view_zoom
    zoom_x = mzoom / max_vzoom
    
    s = (Graphics.height - 416) / 2.0
    snap_dist = (5.8 + s / 32.0) * 32.0 - 8.0
    y_snap = Graphics.height / 2.0 + snap_dist
    
    adj_bottom = WdTk.include?(:Veh3D_OP3) ?
                   386.0 + s * 2.0 - (298.0 + s) * mzoom :
                   88.0 + s
    
    zoom_min = 1.333 / mzoom
    
    d = y_snap - adj_bottom
    l_half = (Graphics.width / 2.0) / zoom_min
    
    new_gh = ((l_half + d) * Math.sqrt(2) / zoom_x).ceil + 4
    needed_padding = (new_gh / 2.0).ceil + 2
    
    if needed_padding > WdTk::Veh3D::OP2.padding
      WdTk::Veh3D::OP2.padding = needed_padding
    end
  end
  
end # WdTk::Veh3D::WS

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================

class << DataManager
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_ws_init, :init unless $@
  
  #--------------------------------------------------------------------------
  # * Initialize Module                                               [Alias]
  #--------------------------------------------------------------------------
  def init
    _wdtk_veh3d_ws_init
    WdTk::Veh3D::WS.ensure_padding
  end
  
end # DataManager

#==============================================================================
# ** Spriteset_Vehicle
#------------------------------------------------------------------------------
#  This class brings together vehicle screen sprites for the pseudo-3D effect.
# It's used within the Scene_Map class and is a subclass of Spriteset_Map.
#==============================================================================

class Spriteset_Vehicle < Spriteset_Map
  #--------------------------------------------------------------------------
  # * Alias Method Definitions                                       [Custom]
  #--------------------------------------------------------------------------
  alias_method :_wdtk_veh3d_ws_update_snap, :update_snap unless $@
  
  #--------------------------------------------------------------------------
  # * Update Snapshot                                                 [Alias]
  #--------------------------------------------------------------------------
  def update_snap
    _wdtk_veh3d_ws_update_snap
    return unless WdTk.include?(:Veh3D_OP2)
    
    vzoom = @vehicle.view_zoom
    old_gh = @snap_sprite.src_rect.width
    old_gx = ((Graphics.width * vzoom - old_gh) / 2.0).round
    zoom_x = @snap_sprite.zoom_x
    
    snap_ox = @snap_sprite.ox + old_gx
    snap_oy = @snap_sprite.oy
    sx = @snap_sprite.src_rect.x - old_gx
    sy = @snap_sprite.src_rect.y
    
    d = @snap_sprite.y - @vehicle.adjust_oy(0)
    zoom_min = @vehicle.adjust_zoom(0)
    l_half = (Graphics.width / 2.0) / zoom_min
    
    new_gh = [old_gh, ((l_half + d) * Math.sqrt(2) / zoom_x).ceil + 4].max
    return if new_gh <= old_gh
    
    new_src_x = (sx + snap_ox - new_gh / 2.0).round
    new_src_y = (sy + snap_oy - new_gh / 2.0).round
    
    @snap_sprite.src_rect.set(new_src_x, new_src_y, new_gh, new_gh)
    @snap_sprite.ox = (new_gh / 2.0).round
    @snap_sprite.oy = (new_gh / 2.0).round
  end
  
end # Spriteset_Vehicle

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
