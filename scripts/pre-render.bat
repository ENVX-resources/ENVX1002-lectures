@echo off
REM Clean _site and stale HTML from source dirs before rendering

REM Remove _site directory if it exists
if exist "_site" (
    rmdir /s /q "_site"
)

REM Delete all HTML files in lectures except index.html
for /r "lectures" %%F in (*.html) do (
    if /I not "%%~nxF"=="index.html" (
        del /q "%%F"
    )
)

REM Remove directories ending with _files
for /d /r "lectures" %%D in (*_files) do (
    rmdir /s /q "%%D"
)

echo Cleaned _site/ and stale render artifacts