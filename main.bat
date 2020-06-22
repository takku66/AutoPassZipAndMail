@echo off
cd %~dp0

rem パスワード用の変数を用意しておく
SET PASS=

rem Script設置フォルダパス
SET CURRENT_DIR=%~dp0

rem 実行プログラムパスを取得する
SET POWERSHELL="C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe"
 
rem 呼び出すスクリプトを指定
SET GET_PASS=%CURRENT_DIR%get_rndm_pass.ps1
SET CONV_ZIP=%CURRENT_DIR%conv_zip.ps1
SET OUT_CONTENT=%CURRENT_DIR%out_mail_content.ps1
SET CREATE_MAIL_DRAFT=%CURRENT_DIR%create_mail_draft.ps1


echo %GET_PASS%
echo %CONV_ZIP%
echo %CREATE_MAIL_DRAFT%

timeout 10

setlocal enabledelayedexpansion
rem ランダムパスワード取得ファイル実行
FOR /F "usebackq delims=" %%a IN (`%POWERSHELL% -executionpolicy bypass -File %GET_PASS%`) DO (
	SET PASS=%%a
)
if %errorlevel% neq 0 (
	call :error %GET_PASS%
	goto end
)

echo "ランダムパスワード取得処理終了"
timeout 10

rem パスワード付きZIPファイル作成処理実行
FOR /F "usebackq delims=" %%a IN (`%POWERSHELL% -executionpolicy bypass -File %CONV_ZIP% !PASS!`) DO (
	SET ZIP_FILE_NAME=%%a
)
if %errorlevel% neq 0 (
	call :error %CONV_ZIP%
	goto end
)
echo "パスワード月ZIPファイル作成処理終了"

rem 下書きメール作成処理実行
FOR /F "usebackq delims=" %%i IN (`%POWERSHELL% -executionpolicy bypass -File %CREATE_MAIL_DRAFT% !PASS!`) DO SET VALUE=%%i
if %errorlevel% neq 0 (
	call :error %CREATE_MAIL_DRAFT
	goto end
)
echo "下書きメール作成処理終了"

goto end
endlocal


:error
echo %1 "の処理中エラーが発生したため、処理を中断します。"
exit /b 1


:end
exit /b 0