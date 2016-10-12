@echo off
:: Runs the Cygwin setup tool to install the specified package.
:: ** Assuming that a base Cygwin installation must be in place first
::    before this batch file can be used to add additional packages

set installer="C:\Users\%USERNAME%\Downloads\setup-x86_64.exe"
echo Installer: %installer%

if not exist %installer% echo Error - cannot find installer %installer
if not exist %installer% goto EOF

if "%1a"=="a" goto GETNAME
set pkgname=%1
goto :DOINSTALL

:GETNAME
set /p pkgname="Enter name of package to install: "

:DOINSTALL
echo Package to install: %pkgname%
%installer% --quiet-mode --packages %pkgname%

:EOF
pause
