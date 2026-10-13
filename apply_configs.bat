@echo off
chcp 1251 >nul
setlocal EnableExtensions
title Менеджер окружения: MyDockFinder, Wallpaper Engine, Cursors & Terminal

REM Определение базовой папки скрипта
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "SRC_MYDOCK=%SCRIPT_DIR%\configs\mydockfinder"
set "SRC_WALLPAPER=%SCRIPT_DIR%\configs\wallpaper_engine"
set "SRC_CURSOR_DEFAULT=%SCRIPT_DIR%\configs\cursor"
set "SRC_CURSOR_ALT=C:\Users\2004i\Downloads\Material_Design_Rounded (2)\Material Design Rounded\Dark"
set "SRC_TERMINAL=%SCRIPT_DIR%\configs\terminal"

:menu
cls
echo.
echo  ================================================================================
echo                      E N V W I N   B Y   V E T R O
echo             Менеджер переноса и настройки окружения Windows
echo  ================================================================================
echo.
echo   [!] ВНИМАНИЕ ДЛЯ ПОЛЬЗОВАТЕЛЯ:
echo       Если у вас сейчас есть сохраненные настройки, иконки, GIF или курсоры,
echo       они будут ПОЛНОСТЬЮ ПЕРЕЗАПИСАНЫ (заменены) новыми конфигами!
echo.
echo  --------------------------------------------------------------------------------
echo   Выберите действие (выполняется только одно за раз):
echo  --------------------------------------------------------------------------------
echo.
echo    [1] Применить конфиг MyDockFinder       (иконки, тема и настройки)
echo    [2] Применить конфиг Wallpaper Engine   (GIF, плейлисты и настройки)
echo    [3] Установить и применить курсор       (Material Design Rounded Dark)
echo    [4] Настроить Windows Terminal          (Tokyo Night, Acrylic Blur, Prompt)
echo    [0] Выход
echo.
set "CHOICE="
set /p "CHOICE= Введите номер действия [1, 2, 3, 4, 0]: "

REM Очистка от кавычек
if defined CHOICE set "CHOICE=%CHOICE:"=%"

if "%CHOICE%"=="1" goto apply_mydock
if "%CHOICE%"=="2" goto apply_wallpaper
if "%CHOICE%"=="3" goto apply_cursor
if "%CHOICE%"=="4" goto apply_terminal
if "%CHOICE%"=="0" goto end_script
if /i "%CHOICE%"=="q" goto end_script

echo.
echo  [!] Неверный выбор. Пожалуйста, введите 1, 2, 3, 4 или 0.
ping 127.0.0.1 -n 3 >nul
goto menu

REM ================================================================================
REM [1] MYDOCKFINDER
REM ================================================================================
:apply_mydock
cls
echo.
echo  ================================================================================
echo              ПРИМЕНЕНИЕ КОНФИГУРАЦИИ MYDOCKFINDER (ИКОНКИ И НАСТРОЙКИ)
echo  ================================================================================
echo.

if not exist "%SRC_MYDOCK%" (
    echo  [ОШИБКА] Папка с исходными конфигами не найдена:
    echo          "%SRC_MYDOCK%"
    echo.
    pause
    goto menu
)

echo  [*] Поиск папки MyDockFinder...
set "TARGET_DIR="

REM 1. Поиск в реестре Steam App 1787090
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1787090" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
    if exist "%%b" set "TARGET_DIR=%%b"
)
if not defined TARGET_DIR (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1787090" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
        if exist "%%b" set "TARGET_DIR=%%b"
    )
)

REM 2. Поиск по стандартным путям
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

REM 3. Поиск по работающему процессу Dock_64.exe
if not defined TARGET_DIR (
    for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "(Get-Process -Name dock_64 -ErrorAction SilentlyContinue).Path" 2^>nul`) do (
        if exist "%%~dpnp" (
            set "TARGET_DIR=%%~dp"
            if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
        )
    )
)

if defined TARGET_DIR (
    echo  [+] Автоматически найдена папка MyDockFinder:
    echo      "%TARGET_DIR%"
    echo.
    set "USE_AUTO="
    set /p "USE_AUTO= Использовать эту папку? [Y - да / N - указать другую вручную, Enter = Y]: "
    if /i "%USE_AUTO%"=="n" set "TARGET_DIR="
)

if not defined TARGET_DIR (
    echo.
    echo  [!] Папка не определена автоматически.
    :prompt_mydock_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT= Введите абсолютный путь к папке MyDockFinder (с кавычками или без): "
    if not defined USER_INPUT (
        echo  [!] Путь не может быть пустым.
        goto prompt_mydock_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo  [ОШИБКА] Папка не найдена по указанному пути: "%CLEAN_PATH%"
        goto prompt_mydock_path
    )
    if not exist "%CLEAN_PATH%\*" (
        echo  [ОШИБКА] Указанный путь является файлом, а не папкой: "%CLEAN_PATH%"
        goto prompt_mydock_path
    )
    set "TARGET_DIR=%CLEAN_PATH%"
)

echo.
echo  --------------------------------------------------------------------------------
echo   Целевая папка: "%TARGET_DIR%"
echo   ВНИМАНИЕ: Все текущие настройки и иконки в этой папке будут перезаписаны!
echo  --------------------------------------------------------------------------------
set "CONFIRM="
set /p "CONFIRM= Подтверждаете замену? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo  Отменено пользователем.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

tasklist /fi "imagename eq dock_64.exe" 2>nul | findstr /i "dock_64.exe" >nul
if not errorlevel 1 (
    echo  [*] Обнаружен запущенный процесс MyDockFinder. Завершаем процесс...
    taskkill /F /IM dock_64.exe /IM Dockmod64.exe /IM Dockmod.exe /IM Mydock.exe /IM trayico.exe >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

echo.
echo  [*] Копирование файлов настроек и иконок...

if exist "%SRC_MYDOCK%\config.ini" (
    copy /Y "%SRC_MYDOCK%\config.ini" "%TARGET_DIR%\config.ini" >nul
    echo   [+] config.ini скопирован.
)
if exist "%SRC_MYDOCK%\ico.ini" (
    copy /Y "%SRC_MYDOCK%\ico.ini" "%TARGET_DIR%\ico.ini" >nul
    echo   [+] ico.ini скопирован.
)
if exist "%SRC_MYDOCK%\ico_bak.ini" (
    copy /Y "%SRC_MYDOCK%\ico_bak.ini" "%TARGET_DIR%\ico_bak.ini" >nul
)
if exist "%SRC_MYDOCK%\keyboard.ini" (
    copy /Y "%SRC_MYDOCK%\keyboard.ini" "%TARGET_DIR%\keyboard.ini" >nul
    echo   [+] keyboard.ini скопирован.
)
if exist "%SRC_MYDOCK%\padconfig.xml" (
    copy /Y "%SRC_MYDOCK%\padconfig.xml" "%TARGET_DIR%\padconfig.xml" >nul
    echo   [+] padconfig.xml скопирован.
)

if exist "%SRC_MYDOCK%\themes" (
    echo  [*] Копирование тем оформления и иконок...
    xcopy "%SRC_MYDOCK%\themes" "%TARGET_DIR%\themes\" /E /I /Y /Q >nul
    echo   [+] Темы оформления и иконки скопированы.
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
echo  ================================================================================
echo   [УСПЕХ] Конфигурация MyDockFinder успешно применена!
echo  ================================================================================
echo.

set "LAUNCH="
set /p "LAUNCH= Запустить MyDockFinder прямо сейчас? [Y/N, Enter = Y]: "
if /i "%LAUNCH%"=="" set "LAUNCH=Y"
if /i "%LAUNCH%"=="y" (
    echo  Запуск MyDockFinder...
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
echo.
echo  ================================================================================
echo           ПРИМЕНЕНИЕ КОНФИГУРАЦИИ WALLPAPER ENGINE (GIF И НАСТРОЙКИ)
echo  ================================================================================
echo.

if not exist "%SRC_WALLPAPER%" (
    echo  [ОШИБКА] Папка с исходными конфигами не найдена:
    echo          "%SRC_WALLPAPER%"
    echo.
    pause
    goto menu
)

echo  [*] Поиск папки Wallpaper Engine...
set "TARGET_DIR="

REM 1. Поиск в реестре Steam App 431960
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 431960" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
    if exist "%%b" set "TARGET_DIR=%%b"
)
if not defined TARGET_DIR (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 431960" /v InstallLocation 2^>nul ^| findstr /i "InstallLocation"') do (
        if exist "%%b" set "TARGET_DIR=%%b"
    )
)

REM 2. Поиск по стандартным путям
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

REM 3. Поиск по работающему процессу wallpaper64.exe
if not defined TARGET_DIR (
    for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "(Get-Process -Name wallpaper64 -ErrorAction SilentlyContinue).Path" 2^>nul`) do (
        if exist "%%~dpnp" (
            set "TARGET_DIR=%%~dp"
            if "!TARGET_DIR:~-1!"=="\" set "TARGET_DIR=!TARGET_DIR:~0,-1!"
        )
    )
)

if defined TARGET_DIR (
    echo  [+] Автоматически найдена папка Wallpaper Engine:
    echo      "%TARGET_DIR%"
    echo.
    set "USE_AUTO="
    set /p "USE_AUTO= Использовать эту папку? [Y - да / N - указать другую вручную, Enter = Y]: "
    if /i "%USE_AUTO%"=="n" set "TARGET_DIR="
)

if not defined TARGET_DIR (
    echo.
    echo  [!] Папка не определена автоматически.
    :prompt_wallpaper_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT= Введите абсолютный путь к папке Wallpaper Engine (с кавычками или без): "
    if not defined USER_INPUT (
        echo  [!] Путь не может быть пустым.
        goto prompt_wallpaper_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo  [ОШИБКА] Папка не найдена по указанному пути: "%CLEAN_PATH%"
        goto prompt_wallpaper_path
    )
    if not exist "%CLEAN_PATH%\*" (
        echo  [ОШИБКА] Указанный путь является файлом, а не папкой: "%CLEAN_PATH%"
        goto prompt_wallpaper_path
    )
    set "TARGET_DIR=%CLEAN_PATH%"
)

echo.
echo  --------------------------------------------------------------------------------
echo   Целевая папка: "%TARGET_DIR%"
echo   ВНИМАНИЕ: Все текущие настройки и GIF в этой папке будут перезаписаны!
echo  --------------------------------------------------------------------------------
set "CONFIRM="
set /p "CONFIRM= Подтверждаете замену? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo  Отменено пользователем.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

tasklist /fi "imagename eq wallpaper64.exe" 2>nul | findstr /i "wallpaper64.exe" >nul
if not errorlevel 1 (
    echo  [*] Обнаружен запущенный процесс Wallpaper Engine. Завершаем процесс...
    taskkill /F /IM wallpaper64.exe /IM wallpaper32.exe /IM wallpaperservice32.exe >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

echo.
echo  [*] Копирование файлов настроек...

if exist "%SRC_WALLPAPER%\config.json" (
    copy /Y "%SRC_WALLPAPER%\config.json" "%TARGET_DIR%\config.json" >nul
    echo   [+] config.json скопирован.
)

if exist "%SRC_WALLPAPER%\projects" (
    echo  [*] Копирование проектов обоев...
    xcopy "%SRC_WALLPAPER%\projects" "%TARGET_DIR%\projects\" /E /I /Y /Q >nul
    echo   [+] Папка projects скопирована.
)

if exist "%SRC_WALLPAPER%\gifs" (
    echo  [*] Копирование GIF файлов...
    if not exist "%TARGET_DIR%\projects\myprojects" mkdir "%TARGET_DIR%\projects\myprojects"
    xcopy "%SRC_WALLPAPER%\gifs" "%TARGET_DIR%\projects\myprojects\" /E /I /Y /Q >nul
    echo   [+] GIF файлы скопированы в projects\myprojects.
)

if exist "%SRC_WALLPAPER%\workshop" (
    for %%I in ("%TARGET_DIR%\..\..\workshop\content\431960") do set "WORKSHOP_DIR=%%~fI"
    if exist "%WORKSHOP_DIR%" (
        echo  [*] Копирование обоев Workshop в "%WORKSHOP_DIR%"...
        xcopy "%SRC_WALLPAPER%\workshop" "%WORKSHOP_DIR%\" /E /I /Y /Q >nul
        echo   [+] Обои Workshop скопированы.
    )
)

echo.
echo  ================================================================================
echo   [УСПЕХ] Конфигурация Wallpaper Engine успешно применена!
echo  ================================================================================
echo.

set "LAUNCH="
set /p "LAUNCH= Запустить Wallpaper Engine прямо сейчас? [Y/N, Enter = Y]: "
if /i "%LAUNCH%"=="" set "LAUNCH=Y"
if /i "%LAUNCH%"=="y" (
    echo  Запуск Wallpaper Engine...
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
REM [3] КУРСОР MATERIAL DESIGN ROUNDED DARK
REM ================================================================================
:apply_cursor
cls
echo.
echo  ================================================================================
echo            УСТАНОВКА И ПРИМЕНЕНИЕ КУРСОРА MATERIAL DESIGN ROUNDED DARK
echo  ================================================================================
echo.

set "SRC_CURSOR="
if exist "%SRC_CURSOR_DEFAULT%\Install.inf" (
    set "SRC_CURSOR=%SRC_CURSOR_DEFAULT%"
) else if exist "%SRC_CURSOR_ALT%\Install.inf" (
    set "SRC_CURSOR=%SRC_CURSOR_ALT%"
)

if defined SRC_CURSOR (
    echo  [+] Найдена папка с курсором:
    echo      "%SRC_CURSOR%"
    echo.
    set "USE_AUTO_CUR="
    set /p "USE_AUTO_CUR= Использовать эту папку? [Y - да / N - указать другую вручную, Enter = Y]: "
    if /i "%USE_AUTO_CUR%"=="n" set "SRC_CURSOR="
)

if not defined SRC_CURSOR (
    echo.
    echo  [!] Папка с курсором не определена автоматически.
    :prompt_cursor_path
    echo.
    set "USER_INPUT="
    set /p "USER_INPUT= Введите абсолютный путь к папке с курсором (с кавычками или без): "
    if not defined USER_INPUT (
        echo  [!] Путь не может быть пустым.
        goto prompt_cursor_path
    )
    
    set "CLEAN_PATH=%USER_INPUT:"=%"
    if "%CLEAN_PATH:~-1%"=="\" set "CLEAN_PATH=%CLEAN_PATH:~0,-1%"
    
    if not exist "%CLEAN_PATH%" (
        echo  [ОШИБКА] Папка не найдена по указанному пути: "%CLEAN_PATH%"
        goto prompt_cursor_path
    )
    set "SRC_CURSOR=%CLEAN_PATH%"
)

echo.
echo  --------------------------------------------------------------------------------
echo   Исходная папка: "%SRC_CURSOR%"
echo   ВНИМАНИЕ: Текущая схема курсора Windows будет заменена на Material Design Dark!
echo  --------------------------------------------------------------------------------
set "CONFIRM="
set /p "CONFIRM= Подтверждаете установку курсора? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo  Отменено пользователем.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

set "DEST_CURSOR_DIR=%SystemRoot%\Material Design Rounded Dark Cursors"
if not exist "%DEST_CURSOR_DIR%" mkdir "%DEST_CURSOR_DIR%" >nul 2>&1

echo.
echo  [*] Копирование файлов курсора...
xcopy "%SRC_CURSOR%\*.cur" "%DEST_CURSOR_DIR%\" /Y /Q >nul 2>&1
xcopy "%SRC_CURSOR%\*.ani" "%DEST_CURSOR_DIR%\" /Y /Q >nul 2>&1
if exist "%SRC_CURSOR%\Install.inf" copy /Y "%SRC_CURSOR%\Install.inf" "%DEST_CURSOR_DIR%\" >nul 2>&1

echo  [*] Настройка реестра Windows (HKCU\Control Panel\Cursors)...
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

reg add "HKCU\Control Panel\Cursors\Schemes" /v "Material Design Rounded Dark Cursors" /t REG_SZ /d "%DEST_CURSOR_DIR%\pointer.cur,%DEST_CURSOR_DIR%\help.cur,%DEST_CURSOR_DIR%\working.ani,%DEST_CURSOR_DIR%\busy.ani,%DEST_CURSOR_DIR%\precision.cur,%DEST_CURSOR_DIR%\beam.cur,%DEST_CURSOR_DIR%\handwriting.cur,%DEST_CURSOR_DIR%\unavailable.cur,%DEST_CURSOR_DIR%\vert.cur,%DEST_CURSOR_DIR%\horz.cur,%DEST_CURSOR_DIR%\dgn1.cur,%DEST_CURSOR_DIR%\dgn2.cur,%DEST_CURSOR_DIR%\move.cur,%DEST_CURSOR_DIR%\alternate.cur,%DEST_CURSOR_DIR%\link.cur,%DEST_CURSOR_DIR%\person.cur,%DEST_CURSOR_DIR%\pin.cur" /f >nul

echo  [*] Мгновенное применение курсора...
powershell -NoProfile -Command "Add-Type -MemberDefinition '[DllImport(\"\"user32.dll\"\")]public static extern bool SystemParametersInfo(uint a,uint b,IntPtr c,uint d);' -Name 'U' -Namespace 'W'; [W.U]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0)" >nul 2>&1
rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True >nul 2>&1

echo.
echo  ================================================================================
echo   [УСПЕХ] Курсор Material Design Rounded Dark успешно установлен и применён!
echo  ================================================================================
echo.
pause
goto menu


REM ================================================================================
REM [4] WINDOWS TERMINAL & POWERSHELL
REM ================================================================================
:apply_terminal
cls
echo.
echo  ================================================================================
echo        НАСТРОЙКА WINDOWS TERMINAL И POWERSHELL (TOKYO NIGHT, ACRYLIC, PROMPT)
echo  ================================================================================
echo.

if not exist "%SRC_TERMINAL%" (
    echo  [ОШИБКА] Папка с настройками терминала не найдена:
    echo          "%SRC_TERMINAL%"
    echo.
    pause
    goto menu
)

echo   ВНИМАНИЕ: Настройки Windows Terminal и профиль PowerShell будут обновлены!
echo   (Цветовая схема Tokyo Night, прозрачность Acrylic Blur 85%%, кастомный prompt)
echo.
set "CONFIRM="
set /p "CONFIRM= Подтверждаете настройку терминала? [Y/N, Enter = Y]: "
if /i "%CONFIRM%"=="n" (
    echo  Отменено пользователем.
    ping 127.0.0.1 -n 3 >nul
    goto menu
)

echo.
echo  [*] Поиск Windows Terminal...
set "WT_DIR=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if exist "%WT_DIR%" (
    echo  [*] Применение настроек Windows Terminal...
    if exist "%SRC_TERMINAL%\settings.json" (
        copy /Y "%SRC_TERMINAL%\settings.json" "%WT_DIR%\settings.json" >nul
        echo   [+] settings.json обновлён в Windows Terminal.
    )
) else (
    echo  [!] Каталог Windows Terminal не найден. Возможно, приложение не установлено через Store.
)

echo  [*] Настройка профиля PowerShell...
set "PS_PROF_DIR=%USERPROFILE%\Documents\WindowsPowerShell"
if not exist "%PS_PROF_DIR%" mkdir "%PS_PROF_DIR%" >nul 2>&1

if exist "%SRC_TERMINAL%\Microsoft.PowerShell_profile.ps1" (
    copy /Y "%SRC_TERMINAL%\Microsoft.PowerShell_profile.ps1" "%PS_PROF_DIR%\Microsoft.PowerShell_profile.ps1" >nul
    echo   [+] Профиль PowerShell установлен: "%PS_PROF_DIR%\Microsoft.PowerShell_profile.ps1"
)

REM Профиль для PowerShell Core (если установлен)
set "PS7_PROF_DIR=%USERPROFILE%\Documents\PowerShell"
if exist "%PS7_PROF_DIR%" (
    copy /Y "%SRC_TERMINAL%\Microsoft.PowerShell_profile.ps1" "%PS7_PROF_DIR%\Microsoft.PowerShell_profile.ps1" >nul
    echo   [+] Профиль PowerShell 7 обновлён.
)

echo.
echo  ================================================================================
echo   [УСПЕХ] Windows Terminal и PowerShell успешно настроены!
echo  ================================================================================
echo.
pause
goto menu

:end_script
cls
echo.
echo  Выход из программы. До свидания!
ping 127.0.0.1 -n 2 >nul
exit /b 0