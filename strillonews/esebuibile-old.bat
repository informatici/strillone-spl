@ECHO off
:ESECUZIONE
cls
@C:\xampp\php\php radioagg.php
echo.
echo.
echo Aggiornamento del Server ogni ora:
echo.
@TIMEOUT /T 3600
goto ESECUZIONE