@echo off

setlocal enabledelayedexpansion

if exist %WINDIR%\system32\inetsrv\appcmd.exe (
    goto CHCP_Check
) else (
    echo "%WINDIR%\system32\inetsrv\appcmd.exe" not found.
    goto End
)


:CHCP_Check

echo [*] IIS information collection... wait...

set iiscmdpath=%SystemRoot%\System32\inetsrv\appcmd.exe
set cmdchcp=
set cmdfindstr=
set output_folder=Output
set output_txt=IIS-Site-Result.txt

for /f "tokens=3 delims= " %%y in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\Nls\CodePage" ^| find "OEMCP"') do (
    set cmdchcp=%%y

    if "!cmdchcp!" equ "950" (
        set "cmdfindstr=ÀÉ®×"
    ) else (
        set "cmdfindstr=File"
    )

    if defined cmdchcp (
        goto Start
    ) else (
        echo Error, exiting script.
        exit /b 1
    )
)


:Start

if not exist %output_folder% mkdir %output_folder%

echo [*] Web Site Information:
echo --------------------------

for /f "tokens=1 delims=:" %%a in ('%iiscmdpath% list site /text:name') do (
    set siteName=%%a
    set siteID=
    set siteBindings=
    set siteState=
    set sitePath=
    set siteSize=
    set siteSizeUnit=Bytes
    set logformat=
    set logPath=
    set logSizeUnit=Bytes

    for /f "tokens=* delims=" %%b in ('%iiscmdpath% list site "%%a" "/text:site.id"') do (
        set siteID=%%b
    )

    for /f "tokens=* delims=" %%b in ('%iiscmdpath% list site "%%a" "/text:bindings"') do (
        set siteBindings=%%b
    )

    for /f "tokens=* delims=" %%b in ('%iiscmdpath% list site "%%a" "/text:state"') do (
        set siteState=%%b
    )

    for /f "tokens=* delims=" %%b in ('%iiscmdpath% list app "%%a/" "/text:[path='/'].physicalPath"') do (
        set sitePath=%%b
        for /f "tokens=3" %%x in ('dir /a /-c /s "%%b" ^| findstr "%cmdfindstr%"') do set siteSize=%%x
    )

    if !siteSize! geq 1048576 (
        set siteSizeUnit=MB
        set /a siteSize=siteSize/1024/1024
    ) ^
    else if !siteSize! geq 1024 (
        set siteSizeUnit=KB
        set /a siteSize=siteSize/1024
    )

    for /f "tokens=* delims=" %%f in ('%iiscmdpath% list site "%%a" "/text:logfile.logformat"') do (
        set logformat=%%f
    )

    for /f "tokens=* delims=" %%c in ('%iiscmdpath% list site "%%a" "/text:logFile.directory"') do (
        set logPath=%%c
        for /f "tokens=3" %%x in ('dir /a /-c /s "%%c" ^| findstr "%cmdfindstr%"') do set logSize=%%x
    )

    if !logSize! geq 1048576 (
        set logSizeUnit=MB
        set /a logSize=logSize/1024/1024
    ) ^
    else if !logSize! geq 1024 (
        set logSizeUnit=KB
        set /a logSize=logSize/1024
    )

    echo Site Name: !siteName! >> .\%output_folder%\%output_txt%
    echo Site ID: !siteID! >> .\%output_folder%\%output_txt%
    echo Site Bindings: !siteBindings! >> .\%output_folder%\%output_txt%
    echo Site State: !siteState! >> .\%output_folder%\%output_txt%
    echo Site Path: !sitePath! >> .\%output_folder%\%output_txt%
    echo SIte Size: !siteSize! !siteSizeUnit! >> .\%output_folder%\%output_txt%
    echo Log foramt: !logformat! >> .\%output_folder%\%output_txt%
    echo Log Path: !logPath! >> .\%output_folder%\%output_txt%
    echo Log Size: !logSize! !logSizeUnit! >> .\%output_folder%\%output_txt%
    echo. >> .\%output_folder%\%output_txt%
)

type .\%output_folder%\%output_txt%

echo -------------------------------------------------- >> .\%output_folder%\%output_txt%
echo IIS Information >> .\%output_folder%\%output_txt%
echo -------------------------------------------------- >> .\%output_folder%\%output_txt%

echo 1) Application Pool List >> .\%output_folder%\%output_txt%
%WINDIR%\system32\inetsrv\appcmd.exe list apppools >> .\%output_folder%\%output_txt%
echo. >> .\%output_folder%\%output_txt%

echo 2) IIS Module List >> .\%output_folder%\%output_txt%
%WINDIR%\system32\inetsrv\appcmd.exe list module >> .\%output_folder%\%output_txt%
echo. >> .\%output_folder%\%output_txt%

echo 3) URL rewrite >> .\%output_folder%\%output_txt%
%WINDIR%\system32\inetsrv\appcmd.exe list config -section:system.webServer/rewrite/globalRules >> .\%output_folder%\%output_txt%
echo. >> .\%output_folder%\%output_txt%

echo 4) w3wp PID and Applicaton Pool >> .\%output_folder%\%output_txt%
%WINDIR%\system32\inetsrv\appcmd.exe list wp >> .\%output_folder%\%output_txt%
echo. >> .\%output_folder%\%output_txt%

echo 5) iis_iusrs Group >> .\%output_folder%\%output_txt%
net localgroup iis_iusrs >> .\%output_folder%\%output_txt%

echo [*] Copy the applicationHost.config file... wait...
copy %WINDIR%\system32\inetsrv\config\applicationHost.config .\%output_folder%\.

echo [*] Finish.
echo.

pause

goto End


:End
exit /b