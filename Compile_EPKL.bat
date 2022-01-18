@echo off
rem Copyright by krzysiu.net, 2017
rem Licensed as MIT (full text: https://opensource.org/licenses/MIT)
rem Modified for EPKL compilation by DreymaR, 2019-03

SETLOCAL
echo **********************************************
echo *****    EPKL COMPILER, using AHK2EXE    *****
echo **********************************************
echo.

REM *** SET YOUR PATH TO THE AHK COMPILER HERE
set src=Source\
set ahk=AHK-Compiler_v1-1
cd /d "%src%"
echo * Working from %src%

REM *** SHUT DOWN ANY RUNNING EPKL.exe AND SUBPROCESSES TO ALLOW OVERWRITING IT
echo * Stopping any running EPKL processes...
taskkill /F /IM EPKL.exe /T
echo.

REM *** COMPILE FOR UNICODE32
rem echo Please choose binary base:
rem echo 1) Unicode 64 bit
rem echo 2) Unicode 32 bit (default in 3 seconds)
rem echo 3) ANSI 32 bit
rem echo.
rem set binImg1=Unicode 64-bit
rem set binImg2=Unicode 32-bit
rem set binImg3=ANSI 32-bit
rem choice /c 123 /t 2 /d 3 /m "Your choice:"
rem if "%ERRORLEVEL%" == "1" set binImg=%binImg1%
rem if "%ERRORLEVEL%" == "2" set binImg=%binImg2%
rem if "%ERRORLEVEL%" == "3" set binImg=%binImg3%
set binImg=Unicode 32-bit
echo * Compiling as %binImg%
rem echo.
set binImg="%ahk%\%binImg%.bin"

REM *** USE MPRESS COMPRESSION IF AVAILABLE (MAY NOT MATTER?)
rem choice /c yn /t 2 /d y /m "Do you want to compress file using MPRESS? Default in 2 sec.: yes."
rem if "%ERRORLEVEL%" == "1" set doComp=1
rem if "%ERRORLEVEL%" == "2" set doComp=0
echo * Compiling using MPRESS compression
rem echo.
set doComp=1

REM *** %~dpn1 IS THE DRIVE-PATH-NAME OF DROPPED SCRIPT DIR
rem if exist "%~dpn1.ico" set iconPath=/icon "%~dpn1.ico"
set iconPath="Resources\Main.ico"

REM *** THE ORIGINAL SCRIPT WAS DRAG-N-DROP
echo Compiling with %ahk%...
rem ahk2exe /in %1 /out "%~dpn1.exe" %iconParam% /bin "%binImg%.bin" /mpress %doComp%endlocal
rem /ahk /bin /mpress are deprecated, but since when? Probably AHK v1.1.33 so we need to get there first.
rem See https://www.autohotkey.com/docs/Scripts.htm#ahk2exe for more info
%ahk%\ahk2exe /in "EPKL.ahk" /out "..\EPKL.exe" /icon %iconPath% /bin %binImg% /mpress %doComp%
echo.
echo * Done compiling!
echo Press any key to run EPKL or Ctrl+C to quit...
pause >nul
start %~dp0"EPKL.exe"
ENDLOCAL
