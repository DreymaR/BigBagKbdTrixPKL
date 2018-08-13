README for Colemak-eD-ANSI-Vi
=============================

This layout is a work in progress. I'm aiming to make a Vietnamese Colemak that works well with PKL and Colemak[eD].
* Special letters are on AltGr(RAlt) plus letters A D E I O Y W (I and Y are duplicates, to test which one is better)
* Version 1: Accents ´`?~. are on bracket keys as well as AltGr (or Shift) plus brackets and '
* Version 2: Accents ´`?~. are on bracket keys and ; , . as special dual-function dead keys releasing the base character.
* Version 3: Accents ´`?~. are on AltGr plus S T R F P. For SR this coincides with Telex; the rest is geometric/ergonomic.
* Version 4: Accents ´`?~. are on bracket keys as well as AltGr plus R S T.
* This layout was designed to work with a standard US-type ANSI system (Windows) layout with RAlt key not defined as AltGr.
* This type of system layout is typical for US and Vietnamese keyboards.

USAGE:
======

* To use, comment out any active 'layout = ' lines in the [pkl] section of PKL.ini and add this:
    layout = Colemak-eD\Cmk-eD-Vi_ANSI_WIP
* Also, if there are no help images, set displayHelpImage = no
* Then (re)run PKL and hopefully it should work.
