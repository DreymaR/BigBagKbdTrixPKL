DreymaR's Big Bag Of Keyboard Tricks - EPKL
===========================================
<br><br>

The EPKL Compose Import Module
------------------------------
- The EPKL Compose Import module can turn any X11-libs Compose file into an EPKL Compose table.
- It doesn't have a menu entry. I've run it using the Debug hotkey definable in _PKL_main.
- It works from the EPKL_Composer directory, making an .ini file from a Compose.h file in _Inbox.
- It uses a template with a set of regular expression (RegEx) entries to generate the .ini file.
- It uses a keysymdef file to translate keysym names into Unicode points.
- Note: The usual X11 keysymdef.h doesn't always use Unicode! It's fine for normal characters.
- Instead, I used the keysyms.txt file by [Dr Markus Kuhn](https://www.cl.cam.ac.uk/~mgk25/) .
- Of note is also the repo at https://github.com/kragen/xcompose
<br><br>

Manual Edits
------------
- I've done quite a lot of manual edits to the [`_eD_Compose.ini`](/Files/_eD_Compose.ini) file.
- Of course, I've added a lot of sequences of my own!
- You can use either the format in earlier sections there, or the clunkier X11-imported format.
- I've uncommented some X11 sequences that interfered with the CoDeKey, occurring in natural text.
