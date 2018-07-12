;-------------------------------------------------------------------------------------
;
; Generate help images from the active layout
;     Calls InkScape with a .SVG template to generate a set of .PNG help images
;     Images are made for each shift state, also for any dead keys
;     An Extend image is not generated, as these require a special layout
;     Search/replace the template entries by looking up in a KLD-based pdic
;
/*
	eD WIP: Help Image Generator
	- A KLD dictionary between SC in the layout and CO in an .SVG img template. 
	- Remaps should already be applied then!
	- Loops for each state, each key. 
	- Also loop for each dead key and state, determining the output of that key state then show the DK release for it (if present)
	- RegExReplace ##</tspan></text>.
	- One .SVG layer for the DK markings; set each entry to blank if not a DK.
	- DK markings: Search/replace DK only from 'KLD_CO template DK' to next 'inkscape:groupmode="layer"'.
	- Call InkScape with command-line options to generate .png
	- Make images from two areas: ANSI - pos (100, 340) / ISO – pos (100,940). Both have size (812,226).
	- Put images as state#.png in a time-marked subfolder of the layout folder? The DK images in a separate subfolder.
	- If an entry is a dk, run a subfunction to generate that dk's maps?!?
*/

makeHelpImages()
{
	origImgFile := "PKL_eD\ImgGenerator\CmkKbdFig_KLD_template.png
	remapFile   := "PKL_eD\_eD_Remap.ini"
	deadKeyFile := getLayInfo( "dkfile" )	; eD WIP: Set/get a list of the actual current DKs? Or just run a DK fn every time a DK is encountered!?
	imageDir    := getLayInfo( "layDir" ) . "\ImgGen_" . A_Now	; Use local time as a dir label
	kbdType     := getLayInfo( "KbdType" )
	shiftStates := getLayInfo( "shiftStates" )
	pngDic      := ReadKeyLayMapPDic( "CO", "SC", remapFile )	; PDic from the CO of the SVG template to SC	;eD WIP: Is the reverse better here?
	
	Loop, Parse, shiftStates, :				; Shift states are separated by colons
	{
	; Make a copy of pngDic for the stateDic? Then turn it into CO->output?
		state := A_LoopField
		for keySC, valCO in pngDic
		{
			entry := getLayInfo( keySC . "<state etc>" )
			if ( subStr( entry, 1, 2 ) == "dk" ) {
				; How to handle the DK layer?
				; Convert the "dk##" to "dk<basechar>"? Then send ## to the _makeDeadkeyHelpImg()
				_makeDeadkeyHelpImg( pngDic, imageDir )
			} else {
				stateDic := ;
				; DK layer entry should be ""
			}
		}
	}
	_makeOneHelpImg( stateDic, imageDir )
}

_makeDeadkeyHelpImg( byref pdic, imgDir )	; Generate a deadkey image
{
	; NOTE: For now, we haven't got chained dead keys. With those, this function may need to call itself recursively!
	_makeOneHelpImage( pdic, imgDir . "\DeadkeyImages" )
}

_makeOneHelpImg( byref pdic, imgDir )	; Generate an actual image
{
	; Make imgDir
	; Copy the template there
	; Loop
	{
	; 	regExReplace
	;	if ( deadkey )
	}
	; Call InkScape w/ cmd line options
}
