@echo off
echo ===================================================
echo Step 1: Finding and preparing new or changed files...
echo ===================================================
git add .

echo.
echo ===================================================
echo Step 2: Saving a local version (Commit)...
echo ===================================================
git commit -m "Auto backup via up.bat"

echo.
echo ===================================================
echo Step 3: Syncing changes from GitHub (Pulling)...
echo ===================================================
git pull origin main --no-edit

echo.
echo ===================================================
echo Step 4: Uploading files to GitHub (Pushing)...
echo ===================================================
git push origin main

echo.
echo ===================================================
echo DONE! Everything is safely stored on GitHub.
echo ===================================================
pause