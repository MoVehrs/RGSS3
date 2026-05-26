# encoding: utf-8
#==============================================================================
# ▼ Hammy - Vehicle Pseudo-3D × Input Device Tracker v1.01
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 25.05.2026
# -- Requires: Hammy - MKXP-Z Input Device Tracker v1.01+,
#              Vehicle Pseudo-3D Database v3.0 by WoodPenguin,
#              Vehicle Pseudo-3D Main Script v3.0.1 by WoodPenguin
# -- Recommended: None
# -- Credits: WoodPenguin (Vehicle Pseudo-3D system)
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_vehicle_pseudo_3d_idt] = true

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
# This script provides an input device tracker patch for RPG Maker VX Ace
# using WoodPenguin's Vehicle Pseudo-3D system. It restores the per-frame
# device poll that Scene_Vehicle's update_basic override would otherwise skip.
# 
# The system supports tracker polling at the proper position after Input.update
# within the vehicle update cycle, load-time activation guarded by both
# required script checks, and full compatibility with the vehicle scene across
# driving, landing, and interior entry transitions.
# 
# -----------------------------------------------------------------------------
# ► Input Device Tracker Integration Features
# -----------------------------------------------------------------------------
# ★ Restores per-frame device polling inside the vehicle update cycle
# ★ Poll position matches the ordering used in Scene_Base#update_basic
# ★ Activates automatically when both required scripts are loaded
# ★ Safe no-op when either required script is absent
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following 3rd party classes:
# 
# -----------------------------------------------------------------------------
# ► Scene_Vehicle (Class < Scene_Map)
# -----------------------------------------------------------------------------
# ★ Overridden Methods:
#   - update_basic
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# ★ This script requires Hammy - MKXP-Z Input Device Tracker and must be placed
#   BELOW it.
# 
# ★ This script requires WoodPenguin - Vehicle Pseudo-3D Main Script and must
#   be placed BELOW it.
# 
# ★ If using Hammy - Vehicle Pseudo-3D × Interiors, place this script BELOW it.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace running on mkxp-z.
# It will not run on default RPG Maker VX Ace without mkxp-z.
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

if $imported[:hammy_mkxp_z_input_device_tracker] && defined?(WdTk::Veh3D)
  #============================================================================
  # ** Scene_Vehicle
  #----------------------------------------------------------------------------
  #  This class handles the vehicle driving screen. It inherits from Scene_Map
  # and modifies the basic update cycle for device tracker compatibility.
  #============================================================================
  
  class Scene_Vehicle < Scene_Map
    #------------------------------------------------------------------------
    # * Frame Update (Basic)                                     [Overridden]
    #------------------------------------------------------------------------
    def update_basic
      if WdTk::Veh3D.need_update?
        Graphics.frame_rate = WdTk::Veh3D::FrameRate
        Graphics.update
        Graphics.frame_rate = 60
      else
        Graphics.frame_count += 1
      end
      
      Input.update
      Hammy::InputDeviceTracker.update
      WdTk::Veh3D.update
      update_all_windows
    end
    
  end # Scene_Vehicle
end # $imported Guard

#==============================================================================
# 
# ▼ End of File
#
#==============================================================================
