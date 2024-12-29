@echo off
setlocal enabledelayedexpansion

REM 설정 파일 경로
set settings_file=install_settings.ini

REM 설정 파일 존재 여부 확인
if not exist "%settings_file%" (
    echo Error: Settings file "%settings_file%" not found.
    exit /b 1
)

REM 설정 파일에서 값 읽기
for /f "tokens=1,2 delims==" %%A in ('findstr /r "^[^;].*" "%settings_file%"') do (
    set %%A=%%B
)

REM 채널 ID 설정
if "%channel_id%"=="" (
    echo Error: Channel ID not specified in settings file.
    exit /b 1
)

REM 파라미터로 driver_path 받기
if "%~1"=="" (
    echo Error: Driver path not provided as a parameter.
    echo Usage: %~n0 <driver_path> [/c | /l | /log | /logcat]
    exit /b 1
)
set driver_path=%~1

REM 현재 디렉토리를 저장
set current_dir=%cd%

REM 옵션 처리
if /i "%~2"=="/c" (
    cls
)

REM 드라이버 디렉토리로 이동
cd /d "%driver_path%"
if errorlevel 1 (
    echo Error: Failed to navigate to driver path "%driver_path%".
    exit /b 1
)

REM 패키징
echo Packaging driver at "%driver_path%"...
for /f "delims=" %%i in ('smartthings edge:drivers:package') do (
    echo %%i
    echo %%i | findstr /r /c:"\"driverId\":" >nul && for /f "tokens=2 delims=:" %%j in ("%%i") do set driver_id=%%~j
)

REM Driver ID 확인
set driver_id=%driver_id:~1,-1%
if "%driver_id%"=="" (
    echo Error: Driver ID could not be retrieved.
    cd /d "%current_dir%"
    exit /b 1
)

REM 채널에 드라이버 할당
echo Assigning driver ID "%driver_id%" to channel "%channel_id%"...
smartthings edge:channels:assign %driver_id% --channel %channel_id%

REM 드라이버 설치
echo Installing driver ID "%driver_id%" to channel "%channel_id%"...
smartthings edge:drivers:install %driver_id% --channel %channel_id%

REM 로그캣 실행
if /i "%~2"=="/l" or /i "%~2"=="/log" or /i "%~2"=="/logcat" (
    echo Starting logcat for driver ID "%driver_id%"...
    smartthings edge:drivers:logcat %driver_id%
    REM 로그캣 실행 후 대기 (exit 호출하지 않음)
    exit /b 0
)

cd /d "%current_dir%"
echo Done.
exit /b 0
