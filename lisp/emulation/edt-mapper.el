;;; edt-mapper.el  ---  Create an EDT LK-201 Map File for X-Windows Emacs.

;;;                             For GNU Emacs 19

;; Copyright (C) 1994, 1995  Free Software Foundation, Inc.

;; Author: Kevin Gallagher <kgallagh@spd.dsccc.com>
;; Maintainer: Kevin Gallagher <kgallagh@spd.dsccc.com>
;; Keywords: emulations

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;  This emacs lisp program can be used to create an emacs lisp file
;;  that defines the mapping of the user's keyboard under X-Windows to
;;  the LK-201 keyboard function keys and keypad keys (around which
;;  EDT has been designed).  Please read the "Usage" AND "Known
;;  Problems" sections before attempting to run this program.  (The
;;  design of this file, edt-mapper.el, was heavily influenced by
;;  tpu-mapper.el.) 

;;; Usage:

;;  Simply load this file into the X-Windows version of emacs (version 19)
;;  using the following command.

;;    emacs -q -l edt-mapper.el

;;  The "-q" option prevents loading of your .emacs file (commands therein
;;  might confuse this program).

;;  An instruction screen showing the typical LK-201 terminal functions keys
;;  will be displayed, and you will be prompted to press the keys on your
;;  keyboard which you want to emulate the corresponding LK-201 keys.

;;  Finally, you will be prompted for the name of the file to store
;;  the key definitions.  If you chose the default, it will be found
;;  and loaded automatically when the EDT emulation is started.  If
;;  you specify a different file name, you will need to set the
;;  variable "edt-xkeys-file" before starting the EDT emulation.
;;  Here's how you might go about doing that in your .emacs file.

;;    (setq edt-xkeys-file (expand-file-name "~/.my-emacs-x-keys"))

;;; Known Problems:

;;  Sometimes, edt-mapper will ignore a key you press, and just continue to
;;  prompt for the same key.  This can happen when your window manager sucks
;;  up the key and doesn't pass it on to emacs, or it could be an emacs bug.
;;  Either way, there's nothing that edt-mapper can do about it.  You must
;;  press RETURN, to skip the current key and continue.  Later, you and/or
;;  your local X guru can try to figure out why the key is being ignored.

;; ====================================================================

;;;
;;;  Revision Information
;;;
(defconst edt-mapper-revision "$Revision: 1.2 $"
    "Revision Number of EDT X-Windows Emacs Key Mapper.")


;;;
;;;  Make sure we're running X-windows and Emacs version 19
;;;
(cond
 ((not (and window-system (not (string-lessp emacs-version "19"))))
  (insert "

    Whoa!  This isn't going to work...

    You must run edt-mapper.el under X-windows and Emacs version 19.

    Press any key to exit.  ")
  (sit-for 600)
  (kill-emacs t)))


;;;
;;;  Decide whether we're running GNU or Lucid emacs.
;;;
(defconst edt-lucid-emacs19-p (string-match "Lucid" emacs-version)
  "Non-NIL if we are running Lucid Emacs version 19.")


;;;
;;;  Key variables
;;;
(defvar edt-key nil)
(defvar edt-enter nil)
(defvar edt-return nil)
(defvar edt-key-seq nil)
(defvar edt-enter-seq nil)
(defvar edt-return-seq nil)


;;;
;;;  Make sure the window is big enough to display the instructions
;;;
(if edt-lucid-emacs19-p (set-screen-size nil 80 36)
  (set-frame-size (selected-frame) 80 36))


;;;
;;;  Create buffers - Directions and Keys
;;;
(if (not (get-buffer "Directions")) (generate-new-buffer "Directions"))
(if (not (get-buffer "Keys")) (generate-new-buffer "Keys"))

;;;
;;;  Put header in the Keys buffer
;;;
(set-buffer "Keys")
(insert "\
;;
;;  Key definitions for the EDT emulation within GNU Emacs
;;

(defconst *EDT-keys*
  '(
")

;;;
;;;   Display directions
;;;
(switch-to-buffer "Directions")
(insert "
                                  EDT MAPPER

    You will be asked to press keys to create a custom mapping (under
    X-Windows) of your keypad keys and function keys so that they can emulate
    the LK-201 keypad and function keys or the subset of keys found on a 
    VT-100 series terminal keyboard.  (The LK-201 keyboard is the standard
    keyboard attached to VT-200 series terminals, and above.)  

    Sometimes, edt-mapper will ignore a key you press, and just continue to
    prompt for the same key.  This can happen when your window manager sucks
    up the key and doesn't pass it on to emacs, or it could be an emacs bug.
    Either way, there's nothing that edt-mapper can do about it.  You must
    press RETURN, to skip the current key and continue.  Later, you and/or
    your local X guru can try to figure out why the key is being ignored.

    Start by pressing the RETURN key, and continue by pressing the keys
    specified in the mini-buffer.  If you want to entirely omit a key, 
    because your keyboard does not have a corresponding key, for example, 
    just press RETURN at the prompt.

")
(delete-other-windows)

;;;
;;;  Save <CR> for future reference
;;;
(cond
 (edt-lucid-emacs19-p
  (setq edt-return-seq (read-key-sequence "Hit carriage-return <CR> to continue "))
  (setq edt-return (concat "[" (format "%s" (event-key (aref edt-return-seq 0))) "]")))
 (t
  (message "Hit carriage-return <CR> to continue ")
  (setq edt-return-seq (read-event))
  (setq edt-return (concat "[" (format "%s" edt-return-seq) "]")))) 

;;;
;;;   Display Keypad Diagram and Begin Prompting for Keys
;;;
(set-buffer "Directions")
(delete-region (point-min) (point-max))
(insert "



          PRESS THE KEY SPECIFIED IN THE MINIBUFFER BELOW.




    Here's a picture of the standard LK-201 keypad for reference:

          _______________________    _______________________________
         | HELP  |      DO       |  |  F17  |  F18  |  F19  |  F20  |
         |       |               |  |       |       |       |       |
         |_______|_______________|  |_______|_______|_______|_______|
          _______________________    _______________________________
         | FIND  |INSERT |REMOVE |  |  PF1  |  PF2  |  PF3  |  PF4  |
         |       |       |       |  |       |       |       |       |
         |_______|_______|_______|  |_______|_______|_______|_______|
         |SELECT |PREVIOU| NEXT  |  |  KP7  |  KP8  |  KP9  |  KP-  |
         |       |       |       |  |       |       |       |       |
         |_______|_______|_______|  |_______|_______|_______|_______|
                 |   UP  |          |  KP4  |  KP5  |  KP6  |  KP,  |
                 |       |          |       |       |       |       |
          _______|_______|_______   |_______|_______|_______|_______|
         |  LEFT |  DOWN | RIGHT |  |  KP1  |  KP2  |  KP3  |       |
         |       |       |       |  |       |       |       |       |
         |_______|_______|_______|  |_______|_______|_______|  KPE  |
                                    |      KP0      |  KPP  |       |
                                    |               |       |       |
                                    |_______________|_______|_______|

")

;;;
;;;  Key mapping functions
;;;
(defun edt-lucid-map-key (ident descrip func gold-func)
  (interactive)
  (setq edt-key-seq (read-key-sequence (format "Press %s%s: " ident descrip)))
  (setq edt-key (concat "[" (format "%s" (event-key (aref edt-key-seq 0))) "]"))
  (cond ((not (equal edt-key edt-return))
	 (set-buffer "Keys")
	 (insert (format "    (\"%s\" . %s)\n" ident edt-key))
	 (set-buffer "Directions"))
	;; bogosity to get next prompt to come up, if the user hits <CR>!
	;; check periodically to see if this is still needed...
	(t
	 (format "%s" edt-key)))
  edt-key)

(defun edt-gnu-map-key (ident descrip)
  (interactive)
  (message "Press %s%s: " ident descrip)
  (setq edt-key-seq (read-event))
  (setq edt-key (concat "[" (format "%s" edt-key-seq) "]"))
  (cond ((not (equal edt-key edt-return))
	 (set-buffer "Keys")
	 (insert (format "    (\"%s\" . %s)\n" ident edt-key))
	 (set-buffer "Directions"))
	;; bogosity to get next prompt to come up, if the user hits <CR>!
	;; check periodically to see if this is still needed...
	(t
	 (set-buffer "Keys")
	 (insert (format "    (\"%s\" . \"\" )\n" ident))
	 (set-buffer "Directions")))
  edt-key)

(fset 'edt-map-key (if edt-lucid-emacs19-p 'edt-lucid-map-key 'edt-gnu-map-key))
(set-buffer "Keys")
(insert "
;;
;;  Arrows
;;
")
(set-buffer "Directions")

(edt-map-key "UP"     " - The Up Arrow Key")
(edt-map-key "DOWN"   " - The Down Arrow Key")
(edt-map-key "LEFT"   " - The Left Arrow Key")
(edt-map-key "RIGHT"  " - The Right Arrow Key")


(set-buffer "Keys")
(insert "
;;
;;  PF keys
;;
")
(set-buffer "Directions")

(edt-map-key "PF1"  " - The PF1 (GOLD) Key")
(edt-map-key "PF2"  " - The Keypad PF2 Key")
(edt-map-key "PF3"  " - The Keypad PF3 Key")
(edt-map-key "PF4"  " - The Keypad PF4 Key")

(set-buffer "Keys")
(insert "
;;
;;  KP0-9 KP- KP, KPP and KPE
;;
")
(set-buffer "Directions")

(edt-map-key "KP0"      " - The Keypad 0 Key")
(edt-map-key "KP1"      " - The Keypad 1 Key")
(edt-map-key "KP2"      " - The Keypad 2 Key")
(edt-map-key "KP3"      " - The Keypad 3 Key")
(edt-map-key "KP4"      " - The Keypad 4 Key")
(edt-map-key "KP5"      " - The Keypad 5 Key")
(edt-map-key "KP6"      " - The Keypad 6 Key")
(edt-map-key "KP7"      " - The Keypad 7 Key")
(edt-map-key "KP8"      " - The Keypad 8 Key")
(edt-map-key "KP9"      " - The Keypad 9 Key")
(edt-map-key "KP-"      " - The Keypad - Key")
(edt-map-key "KP,"      " - The Keypad , Key")
(edt-map-key "KPP"      " - The Keypad . Key")
(edt-map-key "KPE"      " - The Keypad Enter Key")
;; Save the enter key
(setq edt-enter edt-key)
(setq edt-enter-seq edt-key-seq)


(set-buffer "Keys")
(insert "
;;
;;  Editing keypad (FIND, INSERT, REMOVE)
;;                 (SELECT, PREVIOUS, NEXT)
;;
")
(set-buffer "Directions")

(edt-map-key "FIND"      " - The Find key on the editing keypad")
(edt-map-key "INSERT"    " - The Insert key on the editing keypad")
(edt-map-key "REMOVE"    " - The Remove key on the editing keypad")
(edt-map-key "SELECT"    " - The Select key on the editing keypad")
(edt-map-key "PREVIOUS"  " - The Prev Scr key on the editing keypad")
(edt-map-key "NEXT"      " - The Next Scr key on the editing keypad")

(set-buffer "Keys")
(insert "
;;
;;  F1-14 Help Do F17-F20
;;
")
(set-buffer "Directions")

(edt-map-key "F1"        " - F1 Function Key")
(edt-map-key "F2"        " - F2 Function Key")
(edt-map-key "F3"        " - F3 Function Key")
(edt-map-key "F4"        " - F4 Function Key")
(edt-map-key "F5"        " - F5 Function Key")
(edt-map-key "F6"        " - F6 Function Key")
(edt-map-key "F7"        " - F7 Function Key")
(edt-map-key "F8"        " - F8 Function Key")
(edt-map-key "F9"        " - F9 Function Key")
(edt-map-key "F10"       " - F10 Function Key")
(edt-map-key "F11"       " - F11 Function Key")
(edt-map-key "F12"       " - F12 Function Key")
(edt-map-key "F13"       " - F13 Function Key")
(edt-map-key "F14"       " - F14 Function Key")
(edt-map-key "HELP"      " - HELP Function Key")
(edt-map-key "DO"        " - DO Function Key")
(edt-map-key "F17"       " - F17 Function Key")
(edt-map-key "F18"       " - F18 Function Key")
(edt-map-key "F19"       " - F19 Function Key")
(edt-map-key "F20"       " - F20 Function Key")

(set-buffer "Directions")
(delete-region (point-min) (point-max))
(insert "
		       ADDITIONAL FUNCTION KEYS

    Your keyboard may have additional function keys which do not
    correspond to any LK-201 keys.  The EDT Emulation can be
    configured to recognize those keys, since you may wish to add your
    own key bindings to those keys.
    
    For example, suppose your keyboard has a keycap marked \"Line Del\"
    and you wish to add it to the list of keys which can be customized
    by the EDT Emulation.  First, assign a unique single-word name to
    the key for use by the EDT Emulation, let's say \"linedel\", in this
    example.  Then, at the \"EDT Key Name:\" prompt, enter \"linedel\",
    followed by a press of the RETURN key.  Finally, when prompted,
    press the \"Line Del\" key.  You now will be able to bind functions
    to \"linedel\" and \"Gold-linedel\" in edt-user.el in just the same way
    you can customize bindings of the standard LK-201 keys.

    When you have no additional function keys to specify, just press
    RETURN at the \"EDT Key Name:\" prompt.  (If you change your mind
    AFTER you enter an EDT Key Name and before you press a key at the
    \"Press\" prompt, you may omit the key by simply pressing RETURN at
    the prompt.)
")
(switch-to-buffer "Directions")
;;;
;;;  Add support for extras keys
;;;
(set-buffer "Keys")
(insert "\
;;
;;  Extra Keys 
;;
")
(setq EDT-key-name "")
(while (not 
	(string-equal (setq EDT-key-name (read-string "EDT Key Name: ")) ""))
  (edt-map-key EDT-key-name ""))

;
; No more keys to add, so wrap up.
;
(set-buffer "Keys")
(insert "\
    )
  )
")

;;;
;;;  Save the key mapping program and blow this pop stand
;;;
(let ((file (if edt-lucid-emacs19-p "~/.edt-lucid-keys" "~/.edt-gnu-keys")))
  (set-visited-file-name
   (read-file-name (format "Save key mapping to file (default %s): " file) nil file)))
(save-buffer)

(message "That's it!  Press any key to exit")
(sit-for 600)
(kill-emacs t)

;;; edt-mapper.el ends here
