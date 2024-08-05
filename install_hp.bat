@echo on
REM Stel het doelpad in waar het installatieprogramma zich bevindt
set TARGET_DIR="C:\path\to\directory"

REM Voer de stille installatie uit
"%TARGET_DIR%\1. Pre-installatie\Hp Support Assistent\sp146042.exe" /s /a /s /v"/qn"

echo Installatie voltooid.
