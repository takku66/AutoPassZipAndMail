@echo off
cd %~dp0

rem �p�X���[�h�p�̕ϐ���p�ӂ��Ă���
SET PASS=

rem Script�ݒu�t�H���_�p�X
SET CURRENT_DIR=%~dp0

rem ���s�v���O�����p�X���擾����
SET POWERSHELL="C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe"
 
rem �Ăяo���X�N���v�g���w��
SET GET_PASS=%CURRENT_DIR%get_rndm_pass.ps1
SET CONV_ZIP=%CURRENT_DIR%conv_zip.ps1
SET OUT_CONTENT=%CURRENT_DIR%out_mail_content.ps1
SET CREATE_MAIL_DRAFT=%CURRENT_DIR%create_mail_draft.ps1


echo %GET_PASS%
echo %CONV_ZIP%
echo %CREATE_MAIL_DRAFT%

timeout 10

setlocal enabledelayedexpansion
rem �����_���p�X���[�h�擾�t�@�C�����s
FOR /F "usebackq delims=" %%a IN (`%POWERSHELL% -executionpolicy bypass -File %GET_PASS%`) DO (
	SET PASS=%%a
)
if %errorlevel% neq 0 (
	call :error %GET_PASS%
	goto end
)

echo "�����_���p�X���[�h�擾�����I��"
timeout 10

rem �p�X���[�h�t��ZIP�t�@�C���쐬�������s
FOR /F "usebackq delims=" %%a IN (`%POWERSHELL% -executionpolicy bypass -File %CONV_ZIP% !PASS!`) DO (
	SET ZIP_FILE_NAME=%%a
)
if %errorlevel% neq 0 (
	call :error %CONV_ZIP%
	goto end
)
echo "�p�X���[�h��ZIP�t�@�C���쐬�����I��"

rem ���������[���쐬�������s
FOR /F "usebackq delims=" %%i IN (`%POWERSHELL% -executionpolicy bypass -File %CREATE_MAIL_DRAFT% !PASS!`) DO SET VALUE=%%i
if %errorlevel% neq 0 (
	call :error %CREATE_MAIL_DRAFT
	goto end
)
echo "���������[���쐬�����I��"

goto end
endlocal


:error
echo %1 "�̏������G���[�������������߁A�����𒆒f���܂��B"
exit /b 1


:end
exit /b 0