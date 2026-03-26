@echo off
REM get-sha1.bat - Run from the project root to print Android SHA-1 fingerprints.
REM Usage: .\scripts\get-sha1.bat

SETLOCAL ENABLEDELAYEDEXPANSION
echo === GRC POS - SHA-1 helper ===

REM 1) Check JAVA_HOME
if defined JAVA_HOME (
  echo JAVA_HOME=%JAVA_HOME%
) else (
  echo WARNING: JAVA_HOME is not set. keytool may not be available on PATH.
)

echo.
cd /d "%~dp0..\android" || (echo Cannot change to android folder & exit /b 1)

REM 2) If gradlew exists, run signingReport
if exist "gradlew.bat" (
  echo Running gradlew signingReport...
  call gradlew.bat signingReport
  goto :EOF
) else if exist "gradlew" (
  echo Running gradlew signingReport (for msys/git bash)...
  call gradlew signingReport
  goto :EOF
) else (
  echo No Gradle wrapper (gradlew) found in android/. Falling back to keytool.
)

REM 3) Try keytool on default debug keystore
set DEBUG_KEYSTORE=%USERPROFILE%\.android\debug.keystore
if exist "%DEBUG_KEYSTORE%" (
  echo Using debug keystore: %DEBUG_KEYSTORE%
  REM Use keytool from JAVA_HOME if available
  if defined JAVA_HOME (
    "%JAVA_HOME%\bin\keytool" -list -v -keystore "%DEBUG_KEYSTORE%" -alias androiddebugkey -storepass android -keypass android
  ) else (
    echo Attempting to use keytool on PATH...
    keytool -list -v -keystore "%DEBUG_KEYSTORE%" -alias androiddebugkey -storepass android -keypass android
  )
  goto :EOF
) else (
  echo Debug keystore not found at %DEBUG_KEYSTORE%.
  echo You can generate it by running the app once with `flutter run` or create a keystore and then run keytool against it.
)

echo.
echo Manual options:
- Run this from Android Studio: Gradle pane -> :app -> Tasks -> android -> signingReport
- Or install Gradle and run: gradle signingReport in the android/ folder

ENDLOCAL
pause
