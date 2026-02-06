@echo off
REM Build script for The Drift - Godot 4.x (Windows)

setlocal enabledelayedexpansion

set VERSION=%1
if "%VERSION%"=="" set VERSION=0.1.0-beta

set PROJECT_ROOT=%~dp0..
set RELEASE_DIR=%PROJECT_ROOT%\releases
set GODOT_BIN=godot.exe

echo.
echo ===============================================
echo The Drift - Build System (Windows)
echo Version: %VERSION%
echo ===============================================

REM Check if Godot is in PATH
where %GODOT_BIN% >nul 2>nul
if errorlevel 1 (
    echo Error: Godot binary not found
    echo Set GODOT_BIN environment variable to your Godot 4.x executable path
    exit /b 1
)

echo Godot binary: %GODOT_BIN%

REM Create release directory structure
mkdir "%RELEASE_DIR%\windows" 2>nul
mkdir "%RELEASE_DIR%\linux" 2>nul
mkdir "%RELEASE_DIR%\macos" 2>nul

echo.
echo Starting multi-platform build...
echo.

REM Export Windows
echo Exporting Windows Desktop...
cd /d "%PROJECT_ROOT%"
%GODOT_BIN% --headless --export-release "Windows Desktop"
if errorlevel 1 (
    echo Export failed for Windows Desktop
    exit /b 1
)

REM Package Windows build
set WINDOWS_DIR=%RELEASE_DIR%\windows\the-drift-%VERSION%
mkdir "%WINDOWS_DIR%"
copy "%RELEASE_DIR%\windows\*.exe" "%WINDOWS_DIR%\" >nul 2>&1
echo. > "%RELEASE_DIR%\windows\BUILD_INFO.txt"
echo The Drift v%VERSION% >> "%RELEASE_DIR%\windows\BUILD_INFO.txt"
echo Built: %date% %time% >> "%RELEASE_DIR%\windows\BUILD_INFO.txt"

echo.
echo ===============================================
echo Build Complete!
echo ===============================================
echo.
echo Release artifacts created in: %RELEASE_DIR%
echo.

endlocal
