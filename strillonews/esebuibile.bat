@ECHO off
:ESECUZIONE
cls
@C:\xampp\php\php radioagg50x.php
echo.
echo.
echo Aggiornamento del Server ogni 12 ore:
echo.
@TIMEOUT /T 43200
goto ESECUZIONE