@echo off
REM Copy typst PDFs from _site to source directories for committing

for /d %%D in (_site\lectures\L*\) do (
    set "lecture=%%~nxD"
    call :processDir "%%D"
)

goto :eof

:processDir
setlocal
set "dir=%~1"
set "lecture=%~nx1"

for %%F in ("%dir%\*.pdf") do (
    if exist "%%F" (
        copy "%%F" "lectures\%lecture%\" >nul
        echo Copied: %%~nxF ^> lectures\%lecture%\
    )
)

endlocal
goto :eof