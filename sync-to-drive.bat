@echo off
echo Syncing TCM Project to Google Drive...

set GDRIVE_PATH=C:\Users\AvshiSapir\GoogleDrive\My Drive\TCM-Clinical-Assistant

if not exist "%GDRIVE_PATH%" mkdir "%GDRIVE_PATH%"

xcopy /E /Y /I "C:\tcm-clinical-assistant-Tel-Aviv\*" "%GDRIVE_PATH%\" /EXCLUDE:C:\tcm-clinical-assistant-Tel-Aviv\sync-exclude.txt

echo Sync complete! Files are now in Google Drive.
echo Add this folder to NotebookLM: %GDRIVE_PATH%
pause