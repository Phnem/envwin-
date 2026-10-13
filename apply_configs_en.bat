@echo off
setlocal EnableExtensions
title Environment Config Manager: MyDockFinder, Wallpaper Engine and Cursor

REM Script directory resolution
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "SRC_MYDOCK=%SCRIPT_DIR%\configs\mydockfinder"
set "SRC_WALLPAPER=%SCRIPT_DIR%\configs\wallpaper_engine"
set "SRC_CURSOR_DEFAULT=%SCRIPT_DIR%\configs\cursor"
set "SRC_CURSOR_ALT=C:\Users\2004i\Downloads\Material_Design_Rounded (2)\Material Design Rounded\Dark"

:menu
cls
echo ================================================================================
echo                                W A R N I N G !
echo ================================================================================
echo  USER NOTICE:
echo  If you currently have saved settings, icons, GIFs, or cursor schemes in
echo  these applications and your system, they will be COMPLETELY OVERWRITTEN!
echo ================================================================================
echo.
echo  Select an action (only one at a time):
echo.
echo   [1] Apply MyDockFinder config      (icons and settings)
echo   [2] Apply Wallpaper Engine config   (GIFs and settings)
echo   [3] Install and apply cursor scheme (Material Design Rounded Dark)
echo   [0] Exit
echo.
set "CHOICE="
set /p "CHOICE=Enter action number [1, 2, 3, 0]: "

REM Strip quotes
if defined CHOICE set "CHOICE=%CHOICE:"=%"

if "%CHOICE%"=="1" goto apply_mydock
if "%CHOICE%"=="2" goto apply_wallpaper
if "%CHOICE%"=="3" goto apply_cursor
if "%CHOICE%"=="0" goto end_script
if /i "%CHOICE%"=="q" goto end_script

echo.
echo [!] Invalid selection. Please enter 1, 2, 3, or 0.
ping 127.0.0.1 -n 3 >nul
goto menu

REM ================================================================================
REM [1] MYDOCKFINDER
REM ================================================================================
:apply_mydock
cls
echo ================================================================================
echo            APPLYING MYDOCKFINDER CONFIGURATION (ICONS AND SETTINGS)
echo ================================================================================
echo.

REM Verify source folder
if not exist "%SRC_MYDOCK%" (
    echo [ERROR] Source configuration folder not found:
    echo         "%SRC_MYDOCK%"
    echo.
    pause
    goto menu
)

REM Search for MyDockFinder folder
echo [*] Searching for MyDockFinder folder...
set "TARGET_DIR="

REM 1. Steam registry AppID 1787090
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1787090" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
    if exist "%%b" set "TARGET_DIR=%%b"
)
if not defined TARGET_DIR (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1787090" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
        if exist "%%b" set "TARGET_DIR=%%b"
    )
)

REM 2. Standard paths
if not defined TARGET_DIR (
    if exist "%ProgramFiles(x86)%\Steam\steamapps\common\MyDockFinder" set "TARGET_DIR=%ProgramFiles(x86)%\Steam\steamapps\common\MyDockFinder"
)
if not defined TARGET_DIR (
    if exist "%ProgramFiles%\Steam\steamapps\common\MyDockFinder" set "TARGET_DIR=%ProgramFiles%\Steam\steamapps\common\MyDockFinder"
)
if not defined TARGET_DIR (
    if exist "D:\SteamLibrary\steamapps\common\MyDockFinder" set "TARGET_DIR=D:\SteamLibrary\steamapps\common\MyDockFinder"
)
if not defined TARGET_DIR (
    if exist "E:\SteamLibrary\steamapps\common\MyDockFinder" set "TARGET_DIR=E:\SteamLibrary\steamapps\common\MyDockFinder"
)
if not defined TARGET_DIR (
    if exist "C:\MyDockFinder" set "TARGET_DIR=C:\MyDockFinder"
)
if not defined TARGET_DIR (
    if exist "D:\MyDockFinder" set "TARGET_DIR=D:\MyDockFinder"
)

REM 3. Running process Dock_64.exe
if not defined TARGET_DIR (
    for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "(Get-Process -Name dock_64 -ErrorAction SilentlyContinue).Path" 2^>nul`) do (
        if exist "%%~dpnp" (
            set "TARGET_DIR=%%~dp"
            if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
        )
    )
)

REM If found automatically, ask user for confirmation
if defined TARGET_DIR (
    echo [+] Automatically found MyDockFinder folder:
    echo     "%TARGET_DIR%"
    echo.
    set "USE_AUTO="
    set /p "USE_AUTO=Use this folder? [Y - yes / N - specify another manually, Enter = Y]: "
    if /i "%USE_AUTO%"=="n" set "TARGET_DIR="
)

REM If not found or user chose manual input
if not defined TARGET_DIR (
    echo.
    echo [!] Folder could not be detected automatically.
    :prompt_mydock_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT=Enter absolute path to MyDockFinder folder (with or without quotes): "
    if not defined USER_INPUT (
        echo [!] Path cannot be empty.
        goto prompt_mydock_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo [ERROR] Folder not found at specified path: "%CLEAN_PATH%"
        goto prompt_mydock_path
    )
    if not exist "%CLEAN_PATH%\*" (
        echo [ERROR] Specified path is a file, not a directory: "%CLEAN_PATH%"
        goto prompt_mydock_path
    )
    set "TARGET_DIR=%CLEAN_PATH%"
)

echo.
echo ================================================================================
echo Target folder: "%TARGET_DIR%"
echo WARNING: All current settings and icons in this folder will be overwritten!
echo ================================================================================
set "CONFIRM="
set /p "CONFIRM=Confirm replacement? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo Operation cancelled by user.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

REM Terminate running processes for safe file replacement
echo.
tasklist /fi "imagename eq dock_64.exe" 2>nul | findstr /i "dock_64.exe" >nul
if not errorlevel 1 (
    echo [*] Active MyDockFinder process detected. Terminating safely...
    taskkill /F /IM dock_64.exe /IM Dockmod64.exe /IM Dockmod.exe /IM Mydock.exe /IM trayico.exe >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

REM Copy config files
echo.
echo [*] Copying configuration and icon files...

if exist "%SRC_MYDOCK%\config.ini" (
    copy /Y "%SRC_MYDOCK%\config.ini" "%TARGET_DIR%\config.ini" >nul
    echo  [+] config.ini copied.
)
if exist "%SRC_MYDOCK%\ico.ini" (
    copy /Y "%SRC_MYDOCK%\ico.ini" "%TARGET_DIR%\ico.ini" >nul
    echo  [+] ico.ini copied.
)
if exist "%SRC_MYDOCK%\ico_bak.ini" (
    copy /Y "%SRC_MYDOCK%\ico_bak.ini" "%TARGET_DIR%\ico_bak.ini" >nul
)
if exist "%SRC_MYDOCK%\keyboard.ini" (
    copy /Y "%SRC_MYDOCK%\keyboard.ini" "%TARGET_DIR%\keyboard.ini" >nul
    echo  [+] keyboard.ini copied.
)
if exist "%SRC_MYDOCK%\padconfig.xml" (
    copy /Y "%SRC_MYDOCK%\padconfig.xml" "%TARGET_DIR%\padconfig.xml" >nul
    echo  [+] padconfig.xml copied.
)

REM Copy themes and icon packages
if exist "%SRC_MYDOCK%\themes" (
    echo [*] Copying theme skins and custom icons...
    xcopy "%SRC_MYDOCK%\themes" "%TARGET_DIR%\themes\" /E /I /Y /Q >nul
    echo  [+] Themes and icons copied.
)
if exist "%SRC_MYDOCK%\single icon" (
    xcopy "%SRC_MYDOCK%\single icon" "%TARGET_DIR%\single icon\" /E /I /Y /Q >nul
)
if exist "%SRC_MYDOCK%\folderpng" (
    xcopy "%SRC_MYDOCK%\folderpng" "%TARGET_DIR%\folderpng\" /E /I /Y /Q >nul
)
if exist "%SRC_MYDOCK%\png" (
    xcopy "%SRC_MYDOCK%\png" "%TARGET_DIR%\png\" /E /I /Y /Q >nul
)

echo.
echo ================================================================================
echo  [SUCCESS] MyDockFinder configuration applied successfully!
echo ================================================================================
echo.

set "LAUNCH="
set /p "LAUNCH=Launch MyDockFinder now? [Y/N, Enter = Y]: "
if /i "%LAUNCH%"=="" set "LAUNCH=Y"
if /i "%LAUNCH%"=="y" (
    echo Launching MyDockFinder...
    if exist "%TARGET_DIR%\Dock_64.exe" (
        start "" "%TARGET_DIR%\Dock_64.exe"
    ) else if exist "%TARGET_DIR%\dock.exe" (
        start "" "%TARGET_DIR%\dock.exe"
    )
)

echo.
pause
goto menu


REM ================================================================================
REM [2] WALLPAPER ENGINE
REM ================================================================================
:apply_wallpaper
cls
echo ================================================================================
echo        APPLYING WALLPAPER ENGINE CONFIGURATION (GIFS AND SETTINGS)
echo ================================================================================
echo.

REM Verify source folder
if not exist "%SRC_WALLPAPER%" (
    echo [ERROR] Source configuration folder not found:
    echo         "%SRC_WALLPAPER%"
    echo.
    pause
    goto menu
)

REM Search for Wallpaper Engine folder
echo [*] Searching for Wallpaper Engine folder...
set "TARGET_DIR="

REM 1. Steam registry AppID 431960
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 431960" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
    if exist "%%b" set "TARGET_DIR=%%b"
)
if not defined TARGET_DIR (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 431960" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
        if exist "%%b" set "TARGET_DIR=%%b"
    )
)

REM 2. Standard paths
if not defined TARGET_DIR (
    if exist "%ProgramFiles(x86)%\Steam\steamapps\common\wallpaper_engine" set "TARGET_DIR=%ProgramFiles(x86)%\Steam\steamapps\common\wallpaper_engine"
)
if not defined TARGET_DIR (
    if exist "%ProgramFiles%\Steam\steamapps\common\wallpaper_engine" set "TARGET_DIR=%ProgramFiles%\Steam\steamapps\common\wallpaper_engine"
)
if not defined TARGET_DIR (
    if exist "D:\SteamLibrary\steamapps\common\wallpaper_engine" set "TARGET_DIR=D:\SteamLibrary\steamapps\common\wallpaper_engine"
)
if not defined TARGET_DIR (
    if exist "E:\SteamLibrary\steamapps\common\wallpaper_engine" set "TARGET_DIR=E:\SteamLibrary\steamapps\common\wallpaper_engine"
)
if not defined TARGET_DIR (
    if exist "C:\wallpaper_engine" set "TARGET_DIR=C:\wallpaper_engine"
)
if not defined TARGET_DIR (
    if exist "D:\wallpaper_engine" set "TARGET_DIR=D:\wallpaper_engine"
)

REM 3. Running process wallpaper64.exe
if not defined TARGET_DIR (
    for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "(Get-Process -Name wallpaper64 -ErrorAction SilentlyContinue).Path" 2^>nul`) do (
        if exist "%%~dpnp" (
            set "TARGET_DIR=%%~dp"
            if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
        )
    )
)

REM If found automatically, ask user for confirmation
if defined TARGET_DIR (
    echo [+] Automatically found Wallpaper Engine folder:
    echo     "%TARGET_DIR%"
    echo.
    set "USE_AUTO="
    set /p "USE_AUTO=Use this folder? [Y - yes / N - specify another manually, Enter = Y]: "
    if /i "%USE_AUTO%"=="n" set "TARGET_DIR="
)

REM If not found or user chose manual input
if not defined TARGET_DIR (
    echo.
    echo [!] Folder could not be detected automatically.
    :prompt_wallpaper_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT=Enter absolute path to Wallpaper Engine folder (with or without quotes): "
    if not defined USER_INPUT (
        echo [!] Path cannot be empty.
        goto prompt_wallpaper_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo [ERROR] Folder not found at specified path: "%CLEAN_PATH%"
        goto prompt_wallpaper_path
    )
    if not exist "%CLEAN_PATH%\*" (
        echo [ERROR] Specified path is a file, not a directory: "%CLEAN_PATH%"
        goto prompt_wallpaper_path
    )
    set "TARGET_DIR=%CLEAN_PATH%"
)

echo.
echo ================================================================================
echo Target folder: "%TARGET_DIR%"
echo WARNING: All current settings and GIFs in this folder will be overwritten!
echo ================================================================================
set "CONFIRM="
set /p "CONFIRM=Confirm replacement? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo Operation cancelled by user.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

REM Terminate running processes for safe file replacement
echo.
tasklist /fi "imagename eq wallpaper64.exe" 2>nul | findstr /i "wallpaper64.exe" >nul
if not errorlevel 1 (
    echo [*] Active Wallpaper Engine process detected. Terminating safely...
    taskkill /F /IM wallpaper64.exe /IM wallpaper32.exe /IM wallpaperservice32.exe >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

REM Copy config files
echo.
echo [*] Copying configuration files...

if exist "%SRC_WALLPAPER%\config.json" (
    copy /Y "%SRC_WALLPAPER%\config.json" "%TARGET_DIR%\config.json" >nul
    echo  [+] config.json copied.
)

REM Copy user projects
if exist "%SRC_WALLPAPER%\projects" (
    echo [*] Copying wallpaper projects...
    xcopy "%SRC_WALLPAPER%\projects" "%TARGET_DIR%\projects\" /E /I /Y /Q >nul
    echo  [+] projects folder copied.
)

REM Copy GIF files
if exist "%SRC_WALLPAPER%\gifs" (
    echo [*] Copying GIF animation files...
    if not exist "%TARGET_DIR%\projects\myprojects" mkdir "%TARGET_DIR%\projects\myprojects"
    xcopy "%SRC_WALLPAPER%\gifs" "%TARGET_DIR%\projects\myprojects\" /E /I /Y /Q >nul
    echo  [+] GIF files copied to projects\myprojects.
)

REM Copy Workshop items if present
if exist "%SRC_WALLPAPER%\workshop" (
    for %%I in ("%TARGET_DIR%\..\..\workshop\content\431960") do set "WORKSHOP_DIR=%%~fI"
    if exist "%WORKSHOP_DIR%" (
        echo [*] Copying Workshop items to "%WORKSHOP_DIR%"...
        xcopy "%SRC_WALLPAPER%\workshop" "%WORKSHOP_DIR%\" /E /I /Y /Q >nul
        echo  [+] Workshop items copied.
    )
)

echo.
echo ================================================================================
echo  [SUCCESS] Wallpaper Engine configuration applied successfully!
echo ================================================================================
echo.

set "LAUNCH="
set /p "LAUNCH=Launch Wallpaper Engine now? [Y/N, Enter = Y]: "
if /i "%LAUNCH%"=="" set "LAUNCH=Y"
if /i "%LAUNCH%"=="y" (
    echo Launching Wallpaper Engine...
    if exist "%TARGET_DIR%\wallpaper64.exe" (
        start "" "%TARGET_DIR%\wallpaper64.exe"
    ) else if exist "%TARGET_DIR%\wallpaper32.exe" (
        start "" "%TARGET_DIR%\wallpaper32.exe"
    )
)

echo.
pause
goto menu


REM ================================================================================
REM [3] CURSOR SCHEME: MATERIAL DESIGN ROUNDED DARK
REM ================================================================================
:apply_cursor
cls
echo ================================================================================
echo       INSTALLING AND APPLYING CURSOR: MATERIAL DESIGN ROUNDED DARK
echo ================================================================================
echo.

REM Determine cursor source folder
set "SRC_CURSOR="
if exist "%SRC_CURSOR_DEFAULT%\Install.inf" (
    set "SRC_CURSOR=%SRC_CURSOR_DEFAULT%"
) else if exist "%SRC_CURSOR_ALT%\Install.inf" (
    set "SRC_CURSOR=%SRC_CURSOR_ALT%"
)

REM If found automatically
if defined SRC_CURSOR (
    echo [+] Found cursor files in:
    echo     "%SRC_CURSOR%"
    echo.
    set "USE_AUTO_CUR="
    set /p "USE_AUTO_CUR=Use this folder? [Y - yes / N - specify another manually, Enter = Y]: "
    if /i "%USE_AUTO_CUR%"=="n" set "SRC_CURSOR="
)

REM If not found or user chose manual input
if not defined SRC_CURSOR (
    echo.
    echo [!] Cursor directory not determined automatically.
    :prompt_cursor_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT=Enter absolute path to cursor folder (with or without quotes): "
    if not defined USER_INPUT (
        echo [!] Path cannot be empty.
        goto prompt_cursor_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo [ERROR] Folder not found at specified path: "%CLEAN_PATH%"
        goto prompt_cursor_path
    )
    set "SRC_CURSOR=%CLEAN_PATH%"
)

echo.
echo ================================================================================
echo Source folder: "%SRC_CURSOR%"
echo WARNING: Current Windows cursor scheme will be replaced with Material Design Dark!
echo ================================================================================
set "CONFIRM="
set /p "CONFIRM=Confirm cursor installation? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo Operation cancelled by user.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

REM Target destination directory
set "DEST_CURSOR_DIR=%SystemRoot%\Material Design Rounded Dark Cursors"
if not exist "%DEST_CURSOR_DIR%" mkdir "%DEST_CURSOR_DIR%" >nul 2>&1

echo.
echo [*] Copying cursor files to system directory...
xcopy "%SRC_CURSOR%\*.cur" "%DEST_CURSOR_DIR%\" /Y /Q >nul 2>&1
xcopy "%SRC_CURSOR%\*.ani" "%DEST_CURSOR_DIR%\" /Y /Q >nul 2>&1
if exist "%SRC_CURSOR%\Install.inf" copy /Y "%SRC_CURSOR%\Install.inf" "%DEST_CURSOR_DIR%\" >nul 2>&1

REM Windows registry setup
echo [*] Configuring Windows Registry (HKCU\Control Panel\Cursors)...
reg add "HKCU\Control Panel\Cursors" /ve /t REG_SZ /d "Material Design Rounded Dark Cursors" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Arrow /t REG_SZ /d "%DEST_CURSOR_DIR%\pointer.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Help /t REG_SZ /d "%DEST_CURSOR_DIR%\help.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v AppStarting /t REG_SZ /d "%DEST_CURSOR_DIR%\working.ani" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Wait /t REG_SZ /d "%DEST_CURSOR_DIR%\busy.ani" /f >nul
reg add "HKCU\Control Panel\Cursors" /v crosshair /t REG_SZ /d "%DEST_CURSOR_DIR%\precision.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v precisionhair /t REG_SZ /d "%DEST_CURSOR_DIR%\precision.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v IBeam /t REG_SZ /d "%DEST_CURSOR_DIR%\beam.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v NWPen /t REG_SZ /d "%DEST_CURSOR_DIR%\handwriting.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v No /t REG_SZ /d "%DEST_CURSOR_DIR%\unavailable.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v SizeNS /t REG_SZ /d "%DEST_CURSOR_DIR%\vert.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v SizeWE /t REG_SZ /d "%DEST_CURSOR_DIR%\horz.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v SizeNWSE /t REG_SZ /d "%DEST_CURSOR_DIR%\dgn1.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v SizeNESW /t REG_SZ /d "%DEST_CURSOR_DIR%\dgn2.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v SizeAll /t REG_SZ /d "%DEST_CURSOR_DIR%\move.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v UpArrow /t REG_SZ /d "%DEST_CURSOR_DIR%\alternate.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Hand /t REG_SZ /d "%DEST_CURSOR_DIR%\link.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Pin /t REG_SZ /d "%DEST_CURSOR_DIR%\pin.cur" /f >nul
reg add "HKCU\Control Panel\Cursors" /v Person /t REG_SZ /d "%DEST_CURSOR_DIR%\person.cur" /f >nul

REM Add to schemes list
reg add "HKCU\Control Panel\Cursors\Schemes" /v "Material Design Rounded Dark Cursors" /t REG_SZ /d "%DEST_CURSOR_DIR%\pointer.cur,%DEST_CURSOR_DIR%\help.cur,%DEST_CURSOR_DIR%\working.ani,%DEST_CURSOR_DIR%\busy.ani,%DEST_CURSOR_DIR%\precision.cur,%DEST_CURSOR_DIR%\beam.cur,%DEST_CURSOR_DIR%\handwriting.cur,%DEST_CURSOR_DIR%\unavailable.cur,%DEST_CURSOR_DIR%\vert.cur,%DEST_CURSOR_DIR%\horz.cur,%DEST_CURSOR_DIR%\dgn1.cur,%DEST_CURSOR_DIR%\dgn2.cur,%DEST_CURSOR_DIR%\move.cur,%DEST_CURSOR_DIR%\alternate.cur,%DEST_CURSOR_DIR%\link.cur,%DEST_CURSOR_DIR%\person.cur,%DEST_CURSOR_DIR%\pin.cur" /f >nul

REM Apply live via Win32 API
echo [*] Applying cursor instantly to active session...
powershell -NoProfile -Command "Add-Type -MemberDefinition '[DllImport(\"\"user32.dll\"\")]public static extern bool SystemParametersInfo(uint a,uint b,IntPtr c,uint d);' -Name 'U' -Namespace 'W'; [W.U]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)" >nul 2>&1
rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True >nul 2>&1

echo.
echo ================================================================================
echo  [SUCCESS] Material Design Rounded Dark cursor scheme applied successfully!
echo ================================================================================
echo.
pause
goto menu

:end_script
cls
echo Exiting program. Goodbye!
ping 127.0.0.1 -n 2 >nul
exit /b 0
