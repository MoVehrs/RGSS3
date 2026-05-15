# encoding: utf-8
#==============================================================================
# ▼ Hammy - MKXP-Z Input Constants v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 15.05.2026
# -- Requires: mkxp-z (Ruby 3.1)
# -- Recommended: None
# -- Credits: None
# -- License: MIT License
#==============================================================================

$imported ||= {}
$imported[:hammy_mkxp_z_input_constants] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 15.05.2026 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides two sets of named input constants for RPG Maker VX Ace
# running on mkxp-z. It exposes Windows Virtual-Key integer codes and SDL
# scancode symbol aliases as globally accessible named constants.
# 
# The system supports Windows Virtual-Key integer constants for use with
# Input.triggerex? and related ex? methods, SDL scancode symbol aliases that
# resolve the NUMBER_ prefix quirk for top-row digit keys, left and right
# variants for modifier keys, numpad key coverage under the SDL_KP_ prefix,
# and global availability of all constants via Kernel inclusion.
# 
# -----------------------------------------------------------------------------
# ► VK Code Features
# -----------------------------------------------------------------------------
# ★ Windows Virtual-Key integer constants for all common keys
# ★ Mouse button codes as VK_LBUTTON, VK_RBUTTON, and VK_MBUTTON
# ★ Generic and side-specific variants for Shift, Control, and Alt
# ★ Full numpad coverage including arithmetic operators
# ★ Function keys F1 through F24
# ★ OEM punctuation keys for US ANSI layout
# 
# -----------------------------------------------------------------------------
# ► SDL Code Features
# -----------------------------------------------------------------------------
# ★ SDL_KEY_ prefixed constants for letter keys A through Z
# ★ SDL_NUM_ constants resolving the NUMBER_ prefix quirk for digit keys 0-9
# ★ SDL_KP_ constants for all numpad keys including Enter and operators
# ★ Left and right variants for Shift, Control, and Alt modifier keys
# ★ Navigation, lock, function, punctuation, and system key coverage
# 
# -----------------------------------------------------------------------------
# ► Controller Constant Features
# -----------------------------------------------------------------------------
# ★ SDL_BUTTON_ constants for all 15 SDL gamepad buttons (face, d-pad,
#   shoulders, stick clicks, back, guide, start)
# ★ SDL_AXIS_ constants for stick and trigger axes (reference symbols)
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Kernel (Module)
# -----------------------------------------------------------------------------
# ★ Included Modules:
#   - Hammy::VKCodes
#   - Hammy::SDLCodes
# 
#==============================================================================
# ▼ Script Calls
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# The following constants are available for use in events and other scripts.
# All constants are globally accessible without a namespace prefix.
# 
# -----------------------------------------------------------------------------
# ► VK Code Usage
# -----------------------------------------------------------------------------
# ★ Input.triggerex?(VK_ESCAPE)
#   Detects a single-frame trigger on the Escape key via its Virtual-Key code.
# 
# ★ Input.pressex?(VK_LSHIFT)
#   Detects a held state on the Left Shift key via its Virtual-Key code.
# 
# ★ Input.pressex?(VK_LBUTTON)
#   Detects a held state on the left mouse button via its Virtual-Key code.
# 
# -----------------------------------------------------------------------------
# ► SDL Code Usage
# -----------------------------------------------------------------------------
# ★ Input.triggerex?(SDL_KEY_A)
#   Detects a single-frame trigger on the A key via its SDL scancode symbol.
#   Equivalent to Input.triggerex?(:A).
# 
# ★ Input.pressex?(SDL_NUM_7)
#   Detects a held state on the top-row 7 key via its SDL scancode symbol.
#   Equivalent to Input.pressex?(:NUMBER_7).
# 
# ★ Input.triggerex?(SDL_KP_ENTER)
#   Detects a single-frame trigger on the numpad Enter key.
# 
# -----------------------------------------------------------------------------
# ► Mixing VK and SDL Constants
# -----------------------------------------------------------------------------
# ★ Both sets reach the same underlying mkxp-z ex? functions. Mixing is safe:
#   Input.pressex?(VK_LCONTROL) && Input.triggerex?(SDL_KEY_S)
# 
# -----------------------------------------------------------------------------
# ► Controller Usage
# -----------------------------------------------------------------------------
# ★ Input::Controller.pressex?(SDL_BUTTON_START)
#   Detects a held state on the controller Start button.
# 
# ★ Input::Controller.triggerex?(SDL_BUTTON_A)
#   Detects a single-frame trigger on the controller A button.
# 
# ★ SDL_AXIS_ constants are reference symbols for documentation purposes.
#   Actual axis values are read via Input::Controller.axes_left,
#   Input::Controller.axes_right, and Input::Controller.axes_trigger.
#   These methods return arrays of float values and do not use the axis
#   constants directly.
# 
# ★ Some SDL_KEY_ and SDL_BUTTON_ constants resolve to the same symbol.
#   For example, SDL_KEY_A and SDL_BUTTON_A are both :A. mkxp-z
#   distinguishes them by the calling module: Input.triggerex?(:A) checks
#   the keyboard, while Input::Controller.triggerex?(:A) checks the
#   controller.
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains the difference between the two constant sets and when
# to prefer one over the other.
# 
# -----------------------------------------------------------------------------
# ► Choosing Between VK_ and SDL_
# -----------------------------------------------------------------------------
# Both sets call the same mkxp-z ex? functions and produce identical results
# for keys that appear in both. The distinction is stylistic and practical.
# 
# ★ Prefer VK_ constants when working with keys that have well-known Windows
#   Virtual-Key names such as VK_ESCAPE, VK_RETURN, or VK_F5, or when targeting
#   mouse buttons via VK_LBUTTON, VK_RBUTTON, and VK_MBUTTON.
# 
# ★ Prefer SDL_ constants for letter keys and top-row digits where the
#   SDL_KEY_ and SDL_NUM_ prefixes prevent collision with single-letter
#   RGSS constants and hide the NUMBER_ prefix quirk respectively.
# 
# ★ SDL_ constants also cover common punctuation keys that have no
#   VK_ constant defined here, giving every key at least one named constant.
# 
# -----------------------------------------------------------------------------
# ► OEM Key Layout Dependency
# -----------------------------------------------------------------------------
# VK_OEM_1 through VK_OEM_7 are layout-dependent on Windows. The characters
# listed in the constant definitions assume a standard US ANSI keyboard.
# 
# ★ On non-US layouts the same physical key may produce a different character,
#   but the Virtual-Key code assigned to that key position remains the same.
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

#==============================================================================
# ** Hammy::VKCodes
#------------------------------------------------------------------------------
#  This module defines Windows Virtual-Key integer constants for use with
# mkxp-z's ex? input methods. It is included into Kernel for global access.
#==============================================================================

module Hammy
  module VKCodes
    #------------------------------------------------------------------------
    # * Constants (Mouse Buttons)
    #------------------------------------------------------------------------
    VK_LBUTTON = 0x01  # Left   mouse button
    VK_RBUTTON = 0x02  # Right  mouse button
    VK_MBUTTON = 0x04  # Middle mouse button (scroll wheel click)
    
    #------------------------------------------------------------------------
    # * Constants (Editing and Navigation Keys)
    #------------------------------------------------------------------------
    VK_BACK   = 0x08  # Backspace
    VK_TAB    = 0x09  # Tab
    VK_RETURN = 0x0D  # Enter / Return
    VK_ESCAPE = 0x1B  # Escape
    VK_SPACE  = 0x20  # Spacebar
    VK_PRIOR  = 0x21  # Page Up
    VK_NEXT   = 0x22  # Page Down
    VK_END    = 0x23  # End
    VK_HOME   = 0x24  # Home
    VK_LEFT   = 0x25  # Left  Arrow
    VK_UP     = 0x26  # Up    Arrow
    VK_RIGHT  = 0x27  # Right Arrow
    VK_DOWN   = 0x28  # Down  Arrow
    VK_INSERT = 0x2D  # Insert
    VK_DELETE = 0x2E  # Delete
    
    #------------------------------------------------------------------------
    # * Constants (Modifier and Lock Keys)
    #------------------------------------------------------------------------
    VK_SHIFT    = 0x10  # Either Shift (generic)
    VK_CONTROL  = 0x11  # Either Control (generic)
    VK_MENU     = 0x12  # Either Alt / Menu (generic)
    VK_PAUSE    = 0x13  # Pause / Break
    VK_CAPITAL  = 0x14  # Caps Lock
    VK_NUMLOCK  = 0x90  # Num Lock
    VK_SCROLL   = 0x91  # Scroll Lock
    VK_LSHIFT   = 0xA0  # Left  Shift
    VK_RSHIFT   = 0xA1  # Right Shift
    VK_LCONTROL = 0xA2  # Left  Control
    VK_RCONTROL = 0xA3  # Right Control
    VK_LMENU    = 0xA4  # Left  Alt
    VK_RMENU    = 0xA5  # Right Alt
    
    #------------------------------------------------------------------------
    # * Constants (Top-Row Digit Keys)
    #------------------------------------------------------------------------
    VK_0 = 0x30  # 0
    VK_1 = 0x31  # 1
    VK_2 = 0x32  # 2
    VK_3 = 0x33  # 3
    VK_4 = 0x34  # 4
    VK_5 = 0x35  # 5
    VK_6 = 0x36  # 6
    VK_7 = 0x37  # 7
    VK_8 = 0x38  # 8
    VK_9 = 0x39  # 9
    
    #------------------------------------------------------------------------
    # * Constants (Letter Keys)
    #------------------------------------------------------------------------
    VK_A = 0x41  # A
    VK_B = 0x42  # B
    VK_C = 0x43  # C
    VK_D = 0x44  # D
    VK_E = 0x45  # E
    VK_F = 0x46  # F
    VK_G = 0x47  # G
    VK_H = 0x48  # H
    VK_I = 0x49  # I
    VK_J = 0x4A  # J
    VK_K = 0x4B  # K
    VK_L = 0x4C  # L
    VK_M = 0x4D  # M
    VK_N = 0x4E  # N
    VK_O = 0x4F  # O
    VK_P = 0x50  # P
    VK_Q = 0x51  # Q
    VK_R = 0x52  # R
    VK_S = 0x53  # S
    VK_T = 0x54  # T
    VK_U = 0x55  # U
    VK_V = 0x56  # V
    VK_W = 0x57  # W
    VK_X = 0x58  # X
    VK_Y = 0x59  # Y
    VK_Z = 0x5A  # Z
    
    #------------------------------------------------------------------------
    # * Constants (Numpad Keys)
    #------------------------------------------------------------------------
    VK_NUMPAD0  = 0x60  # Numpad 0
    VK_NUMPAD1  = 0x61  # Numpad 1
    VK_NUMPAD2  = 0x62  # Numpad 2
    VK_NUMPAD3  = 0x63  # Numpad 3
    VK_NUMPAD4  = 0x64  # Numpad 4
    VK_NUMPAD5  = 0x65  # Numpad 5
    VK_NUMPAD6  = 0x66  # Numpad 6
    VK_NUMPAD7  = 0x67  # Numpad 7
    VK_NUMPAD8  = 0x68  # Numpad 8
    VK_NUMPAD9  = 0x69  # Numpad 9
    VK_MULTIPLY = 0x6A  # Numpad *
    VK_ADD      = 0x6B  # Numpad +
    VK_SUBTRACT = 0x6D  # Numpad -
    VK_DECIMAL  = 0x6E  # Numpad .
    VK_DIVIDE   = 0x6F  # Numpad /
    
    #------------------------------------------------------------------------
    # * Constants (Function Keys)
    #------------------------------------------------------------------------
    VK_F1  = 0x70  # F1
    VK_F2  = 0x71  # F2
    VK_F3  = 0x72  # F3
    VK_F4  = 0x73  # F4
    VK_F5  = 0x74  # F5
    VK_F6  = 0x75  # F6
    VK_F7  = 0x76  # F7
    VK_F8  = 0x77  # F8
    VK_F9  = 0x78  # F9
    VK_F10 = 0x79  # F10
    VK_F11 = 0x7A  # F11
    VK_F12 = 0x7B  # F12
    VK_F13 = 0x7C  # F13
    VK_F14 = 0x7D  # F14
    VK_F15 = 0x7E  # F15
    VK_F16 = 0x7F  # F16
    VK_F17 = 0x80  # F17
    VK_F18 = 0x81  # F18
    VK_F19 = 0x82  # F19
    VK_F20 = 0x83  # F20
    VK_F21 = 0x84  # F21
    VK_F22 = 0x85  # F22
    VK_F23 = 0x86  # F23
    VK_F24 = 0x87  # F24
    
    #------------------------------------------------------------------------
    # * Constants (OEM and Punctuation Keys)
    #   These codes are layout-dependent on Windows. The characters listed
    #  assume a standard US ANSI keyboard.
    #------------------------------------------------------------------------
    VK_OEM_1      = 0xBA  # ; :
    VK_OEM_PLUS   = 0xBB  # = +
    VK_OEM_COMMA  = 0xBC  # , <
    VK_OEM_MINUS  = 0xBD  # - _
    VK_OEM_PERIOD = 0xBE  # . >
    VK_OEM_2      = 0xBF  # / ?
    VK_OEM_3      = 0xC0  # ` ~
    VK_OEM_4      = 0xDB  # [ {
    VK_OEM_5      = 0xDC  # \ |
    VK_OEM_6      = 0xDD  # ] }
    VK_OEM_7      = 0xDE  # ' "
    
  end # VKCodes
end # Hammy

#==============================================================================
# ** Hammy::SDLCodes
#------------------------------------------------------------------------------
#  This module defines named constants for SDL scancode symbols accepted by
# mkxp-z's ex? input methods. It is included into Kernel for global access.
#==============================================================================

module Hammy
  module SDLCodes
    #------------------------------------------------------------------------
    # * Constants (Controller Buttons)
    #------------------------------------------------------------------------
    SDL_BUTTON_A             = :A             # Controller Button A
    SDL_BUTTON_B             = :B             # Controller Button B
    SDL_BUTTON_X             = :X             # Controller Button X
    SDL_BUTTON_Y             = :Y             # Controller Button Y
    SDL_BUTTON_BACK          = :BACK          # Controller Back button
    SDL_BUTTON_GUIDE         = :GUIDE         # Controller Guide / Home button
    SDL_BUTTON_START         = :START         # Controller Start button
    SDL_BUTTON_LEFTSTICK     = :LEFTSTICK     # Left  Stick click (L3)
    SDL_BUTTON_RIGHTSTICK    = :RIGHTSTICK    # Right Stick click (R3)
    SDL_BUTTON_LEFTSHOULDER  = :LEFTSHOULDER  # Left  Shoulder button (LB)
    SDL_BUTTON_RIGHTSHOULDER = :RIGHTSHOULDER # Right Shoulder button (RB)
    SDL_BUTTON_DPAD_UP       = :DPAD_UP       # D-Pad Up
    SDL_BUTTON_DPAD_DOWN     = :DPAD_DOWN     # D-Pad Down
    SDL_BUTTON_DPAD_LEFT     = :DPAD_LEFT     # D-Pad Left
    SDL_BUTTON_DPAD_RIGHT    = :DPAD_RIGHT    # D-Pad Right
    
    #------------------------------------------------------------------------
    # * Constants (Controller Axes)
    #------------------------------------------------------------------------
    SDL_AXIS_LEFT_X        = :LEFT_X        # Left  Stick X axis (horizontal)
    SDL_AXIS_LEFT_Y        = :LEFT_Y        # Left  Stick Y axis (vertical)
    SDL_AXIS_RIGHT_X       = :RIGHT_X       # Right Stick X axis (horizontal)
    SDL_AXIS_RIGHT_Y       = :RIGHT_Y       # Right Stick Y axis (vertical)
    SDL_AXIS_TRIGGER_LEFT  = :LEFT_TRIGGER  # Left  Trigger axis (LT)
    SDL_AXIS_TRIGGER_RIGHT = :RIGHT_TRIGGER # Right Trigger axis (RT)
    
    #------------------------------------------------------------------------
    # * Constants (Letter Keys)
    #------------------------------------------------------------------------
    SDL_KEY_A = :A  # A
    SDL_KEY_B = :B  # B
    SDL_KEY_C = :C  # C
    SDL_KEY_D = :D  # D
    SDL_KEY_E = :E  # E
    SDL_KEY_F = :F  # F
    SDL_KEY_G = :G  # G
    SDL_KEY_H = :H  # H
    SDL_KEY_I = :I  # I
    SDL_KEY_J = :J  # J
    SDL_KEY_K = :K  # K
    SDL_KEY_L = :L  # L
    SDL_KEY_M = :M  # M
    SDL_KEY_N = :N  # N
    SDL_KEY_O = :O  # O
    SDL_KEY_P = :P  # P
    SDL_KEY_Q = :Q  # Q
    SDL_KEY_R = :R  # R
    SDL_KEY_S = :S  # S
    SDL_KEY_T = :T  # T
    SDL_KEY_U = :U  # U
    SDL_KEY_V = :V  # V
    SDL_KEY_W = :W  # W
    SDL_KEY_X = :X  # X
    SDL_KEY_Y = :Y  # Y
    SDL_KEY_Z = :Z  # Z
    
    #------------------------------------------------------------------------
    # * Constants (Top-Row Digit Keys)
    #------------------------------------------------------------------------
    SDL_NUM_0 = :NUMBER_0  # 0
    SDL_NUM_1 = :NUMBER_1  # 1
    SDL_NUM_2 = :NUMBER_2  # 2
    SDL_NUM_3 = :NUMBER_3  # 3
    SDL_NUM_4 = :NUMBER_4  # 4
    SDL_NUM_5 = :NUMBER_5  # 5
    SDL_NUM_6 = :NUMBER_6  # 6
    SDL_NUM_7 = :NUMBER_7  # 7
    SDL_NUM_8 = :NUMBER_8  # 8
    SDL_NUM_9 = :NUMBER_9  # 9
    
    #------------------------------------------------------------------------
    # * Constants (Editing and Navigation Keys)
    #------------------------------------------------------------------------
    SDL_BACKSPACE = :BACKSPACE  # Backspace
    SDL_TAB       = :TAB        # Tab
    SDL_RETURN    = :RETURN     # Main Enter key
    SDL_ESCAPE    = :ESCAPE     # Escape
    SDL_SPACE     = :SPACE      # Spacebar
    SDL_LEFT      = :LEFT       # Left  Arrow
    SDL_RIGHT     = :RIGHT      # Right Arrow
    SDL_UP        = :UP         # Up    Arrow
    SDL_DOWN      = :DOWN       # Down  Arrow
    
    #------------------------------------------------------------------------
    # * Constants (Extended Navigation Keys)
    #------------------------------------------------------------------------
    SDL_INSERT   = :INSERT    # Insert
    SDL_DELETE   = :DELETE    # Delete
    SDL_HOME     = :HOME      # Home
    SDL_END      = :END       # End
    SDL_PAGEUP   = :PAGEUP    # Page Up
    SDL_PAGEDOWN = :PAGEDOWN  # Page Down
    
    #------------------------------------------------------------------------
    # * Constants (Modifier Keys)
    #------------------------------------------------------------------------
    SDL_LSHIFT   = :LSHIFT    # Left  Shift
    SDL_RSHIFT   = :RSHIFT    # Right Shift
    SDL_LCTRL    = :LCTRL     # Left  Control
    SDL_RCTRL    = :RCTRL     # Right Control
    SDL_LALT     = :LALT      # Left  Alt
    SDL_RALT     = :RALT      # Right Alt  (AltGr on European layouts)
    SDL_CAPSLOCK = :CAPSLOCK  # Caps Lock
    
    #------------------------------------------------------------------------
    # * Constants (Function Keys)
    #------------------------------------------------------------------------
    SDL_F1  = :F1   # F1
    SDL_F2  = :F2   # F2
    SDL_F3  = :F3   # F3
    SDL_F4  = :F4   # F4
    SDL_F5  = :F5   # F5
    SDL_F6  = :F6   # F6
    SDL_F7  = :F7   # F7
    SDL_F8  = :F8   # F8
    SDL_F9  = :F9   # F9
    SDL_F10 = :F10  # F10
    SDL_F11 = :F11  # F11
    SDL_F12 = :F12  # F12
    
    #------------------------------------------------------------------------
    # * Constants (Extended Function Keys)
    #------------------------------------------------------------------------
    SDL_F13 = :F13  # F13
    SDL_F14 = :F14  # F14
    SDL_F15 = :F15  # F15
    SDL_F16 = :F16  # F16
    SDL_F17 = :F17  # F17
    SDL_F18 = :F18  # F18
    SDL_F19 = :F19  # F19
    SDL_F20 = :F20  # F20
    SDL_F21 = :F21  # F21
    SDL_F22 = :F22  # F22
    SDL_F23 = :F23  # F23
    SDL_F24 = :F24  # F24
    
    #------------------------------------------------------------------------
    # * Constants (Numpad Keys)
    #------------------------------------------------------------------------
    SDL_KP_0        = :KP_0          # Numpad 0
    SDL_KP_1        = :KP_1          # Numpad 1
    SDL_KP_2        = :KP_2          # Numpad 2
    SDL_KP_3        = :KP_3          # Numpad 3
    SDL_KP_4        = :KP_4          # Numpad 4
    SDL_KP_5        = :KP_5          # Numpad 5
    SDL_KP_6        = :KP_6          # Numpad 6
    SDL_KP_7        = :KP_7          # Numpad 7
    SDL_KP_8        = :KP_8          # Numpad 8
    SDL_KP_9        = :KP_9          # Numpad 9
    SDL_KP_ENTER    = :KP_ENTER      # Numpad Enter
    SDL_KP_PERIOD   = :KP_PERIOD     # Numpad decimal / Delete
    SDL_KP_PLUS     = :KP_PLUS       # Numpad +
    SDL_KP_MINUS    = :KP_MINUS      # Numpad -
    SDL_KP_MULTIPLY = :KP_MULTIPLY   # Numpad *
    SDL_KP_DIVIDE   = :KP_DIVIDE     # Numpad /
    SDL_NUMLOCK     = :NUMLOCKCLEAR  # Num Lock (SDL name is NUMLOCKCLEAR)
    
    #------------------------------------------------------------------------
    # * Constants (Punctuation and Symbol Keys)
    #------------------------------------------------------------------------
    SDL_MINUS        = :MINUS         # -  (and _ with Shift)
    SDL_EQUALS       = :EQUALS        # =  (and + with Shift)
    SDL_LEFTBRACKET  = :LEFTBRACKET   # [  (and { with Shift)
    SDL_RIGHTBRACKET = :RIGHTBRACKET  # ]  (and } with Shift)
    SDL_BACKSLASH    = :BACKSLASH     # \  (and | with Shift)
    SDL_SEMICOLON    = :SEMICOLON     # ;  (and : with Shift)
    SDL_APOSTROPHE   = :APOSTROPHE    # '  (and " with Shift)
    SDL_GRAVE        = :GRAVE         # `  (and ~ with Shift)
    SDL_COMMA        = :COMMA         # ,  (and < with Shift)
    SDL_PERIOD       = :PERIOD        # .  (and > with Shift)
    SDL_SLASH        = :SLASH         # /  (and ? with Shift)
    
    #------------------------------------------------------------------------
    # * Constants (System Keys)
    #------------------------------------------------------------------------
    SDL_PRINTSCREEN = :PRINTSCREEN  # Print Screen
    SDL_SCROLLLOCK  = :SCROLLLOCK   # Scroll Lock
    SDL_PAUSE       = :PAUSE        # Pause / Break
    
  end # SDLCodes
end # Hammy

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  A module defining the methods that can be referred to by all classes.
#  Object class methods are defined in this module, ensuring compatibility
#  with top-level method redefinition.
#==============================================================================

module Kernel
  include Hammy::VKCodes
  include Hammy::SDLCodes
  
end # Kernel

#==============================================================================
#
# ▼ End of File
#
#==============================================================================
