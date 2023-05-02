@echo off

setlocal enabledelayedexpansion


tasklist /v /fi "imagename eq w3wp.exe"
echo.

set /p pid="Please enter the w3wp.exe PID number: "


set output_folder=Output
if not exist %output_folder% mkdir %output_folder%
set output_handle=.\%output_folder%\Process-handle_PID_%pid%.txt


:: EM64T is very rarely seen, almost always on Windows XP-64.
if "%PROCESSOR_ARCHITECTURE%"=="x86" set IISCC_Bit=32
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set IISCC_Bit=64
if "%PROCESSOR_ARCHITECTURE%"=="IA64" set IISCC_Bit=64
if "%PROCESSOR_ARCHITECTURE%"=="EM64T" set IISCC_Bit=64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set IISCC_Bit=64
if "%PROCESSOR_ARCHITECTURE%"=="ARM32" set IISCC_Bit=32


if "%IISCC_Bit%"=="64" (
    set "handle=.\Modules\handle\handle64.exe"
) else (
    set "handle=.\Modules\handle\handle.exe"
)

%handle% /accepteula -p %pid% > %output_handle%
notepad %output_handle%


pause