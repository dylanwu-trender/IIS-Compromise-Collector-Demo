@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 免責聲明：
:: Script 尚未進行完善的測試，經使用後所產生的任何損失或損害，概不負責，請使用者自行承擔風險。
::
:: Disclaimer:
:: The script has not undergone sufficient testing, and the author assumes no responsibility for any loss or damage incurred by the user.
:: Users assume all risks associated with using the script.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal

cd /d %~dp0
cls


set /a "num=%RANDOM% %% 3 + 1"
if %num% == 1 (
    type .\Modules\Banner\banner-1.txt
) else if %num% == 2 (
    type .\Modules\Banner\banner-2.txt
) else (
    type .\Modules\Banner\banner-3.txt
)

echo.
echo.
echo IIS Compromise Collector (Demo Version)
echo Author: Dylan Wu
echo.
echo [!] Disclaimer: The script has not undergone sufficient testing, and the author assumes no responsibility for any loss or damage incurred by the user. Users assume all risks associated with using the script.

:Check_Permissions
echo [#] Administrator permission required, Checking permission ...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [#] Success: Confirmed as administrator permission.
    goto CHCP_Check
) else (
    echo [!] Failure: Oops! Current permission is insufficient, please run the program with administrator permission.
    goto End
)

:CHCP_Check

setlocal enabledelayedexpansion

:: Get Local IP

goto Endpoint_Information


:Endpoint_Information
echo.
echo --------------------------------------------------
for /F "tokens=*" %%i IN ('whoami') DO set IISCC_whoami=%%i
echo Current Login Account: %IISCC_whoami%
	
for /F "tokens=*" %%i IN ('hostname') DO set IISCC_hostname=%%i
echo Host Name: %IISCC_hostname%

echo Host IP: %IISCC_Local_IP%
echo --------------------------------------------------
echo.

pause


goto Menu

:Menu
cls

echo ::: IIS Compromise Collector :::
echo.
echo [Menu] Choose an option:
echo [0] One-click collection
echo [1] Open IIS Manager
echo [2] IIS information
echo [3] w3wp process check
echo [4] .NET process check
echo [5] .NET temporary check
echo [6] Webshell file scan (Dove)
echo [7] Webshell file scan (Yara)
echo [8] In-memory webshell scan
echo [9] Exchange attack detection
echo [Q] Quit
echo.

set choice=
set /p choice=Enter choice number: 

if "%choice%"=="0" (

    goto Menu
) else if "%choice%"=="1" (
    start "" /b "%WINDIR%\system32\inetsrv\InetMgr.exe"
    goto Menu
) else if "%choice%"=="2" (
    start cmd /k ".\Modules\IIS-Info.bat"
    goto Menu
) else if "%choice%"=="3" (
    start cmd /k ".\Modules\w3wp-ProcessCheck.bat"
    goto Menu
) else if "%choice%"=="4" (
    start "" /b ".\Modules\.NET-ProcessCheck.bat"
    goto Menu
) else if "%choice%"=="5" (
    start %SystemRoot%\Microsoft.NET\Framework\
    goto Menu
) else if "%choice%"=="6" (
    start cmd /k ".\Modules\Dove.bat"
    goto Menu
) else if "%choice%"=="7" (
    start cmd /k ".\Modules\Yara.bat"
    goto Menu
) else if "%choice%"=="8" (

    goto Menu
) else if "%choice%"=="9" (

    goto Menu
) else if /i "%choice%"=="q" (
    exit /b
) else (
    echo Invalid choice. Please try again.
    pause
    goto Menu
)

goto End


:End
pause
exit /b