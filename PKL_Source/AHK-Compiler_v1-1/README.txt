====================================================
   Important Notes for Ahk2Exe for AutoHotkey 1.1
====================================================

1. BIN Files

Scripts are "compiled" by combining them with a .bin file containing
the script interpreter, similar to AutoHotkey.exe.  This version of
Ahk2Exe requires a .bin file compiled from AutoHotkey 1.1 source code
or a compatible fork.  The official download includes three:

  - ANSI 32-bit.bin
  - Unicode 32-bit.bin
  - Unicode 64-bit.bin

One of these should be selected from the "Base File" drop-down list
in the GUI.  If "(Default)" is selected, there must be a file named
AutoHotkeySC.bin in the Ahk2Exe directory.  This is normally created
by the AutoHotkey installer (simply a copy of another bin file).
If this file does not exist, Ahk2Exe will attempt to copy it from
one of the other bin files (typically Unicode 32-bit).


2. AutoHotkey.exe

Function library auto-includes are only supported if a copy of
AutoHotkey.exe exists in the parent directory.  For example:

  C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
  C:\Program Files\AutoHotkey\AutoHotkey.exe

Although this exe doesn't need to be the same version as the current
.bin file, it must at least be able to load (not run) the script you
are attempting to compile.


3. Usage

Usage via the GUI should be self-explanatory.  For command-line
usage, run "Ahk2Exe.exe /?".  For more info, see the documentation:

Offline:  See "ahk2exe" in the AutoHotkey_L help file index.
Online:   https://autohotkey.com/docs/Scripts.htm#ahk2exe

