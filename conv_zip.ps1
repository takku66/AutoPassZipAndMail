# ���s�t�H���_���擾
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# ���s�t�@�C�����擾
$PsFileName = $MyInvocation.MyCommand.Name;

# ���O�o�͗p�N����
$Now = (Get-Date).ToString("yyyy/mm/dd hh:mm:ss ");

function outLog($logType, $logContent){
    if($logType -eq "E"){
        "$Now Error  :  $logContent">>$CurrentDir\$Log;
    }elseif($logType -eq "W"){
        "$Now Warning:  $logContent">>$CurrentDir\$Log;
    }elseif($logType -eq "I"){
        "$Now Info   :  $logContent">>$CurrentDir\$Log;
    }else{
        "">>$CurrentDir\$Log;
    }

    if($Debug){
        Write-Debug "$Now $logContent";
    }
}


try{
    # �eJSON�t�@�C����ǂݍ���
    $SystemJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\system.json -Raw);
    $PassJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\pass.json -Raw);
    $ZipJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\zip.json -Raw);
    $MailJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\mail.json -Raw);
    # ���O�t�@�C��
    $Log = $SystemJson.log_file;
    # �f�o�b�O���[�h
    $Debug = $SystemJson.debug_mode;
    outLog "" "";
    outLog "I" "�����J�n�F[$PsFileName]";
}catch{
    outLog "E" "Json�t�@�C���̓ǂݍ��ݒ��ɃG���[���������܂����B";
    outLog "E" $_.Exception;
}

# �������擾����
$ZipPass = $args[0];

# zip�����W���[�����w��
$ZipProgram = $SystemJson.zip_module;

# zip�Ώۂ̃t�H���_���w��
$ZipTargetDir = $ZipJson.target_path;

# zip�Ώۂ̃t�H���_���w��
$ZipTargetFile = $ZipJson.target_file;

$ZipTargetFiles = @(Get-ChildItem ($ZipTargetDir + "\" + $ZipTargetFile) -Include *);

outLog "I" "zip���p�����[�^�擾����";

# zip��
if($Debug){
	Write-host "Zip�����W���[��= "$ZipProgram
	#Write-host "���W���[������= "$ZipModuleArgs
	Write-host "Zip���Ώۃt�H���_= "$ZipTargetDir
	Write-host "Zip���Ώۃt�@�C��= "$ZipTargetFile
	Write-host "Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$ZipTargetDir\$ZipTargetFile;"
}

try{
    foreach($zipFile in $ZipTargetFiles){
        #Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$zipFile;
        & "$ZipProgram" /c:zip /o:$ZipTargetDir /p:$ZipPass "$zipFile"
    }
        
}catch{
    outLog "E" "zip�����ɃG���[";
    outLog "E" $_.Exception;
}
outLog "I" "zip���I��";

Start-Sleep -s 5


# ���M�Ώۂ̃t�@�C�������擾
Get-ChildItem $ZipTargetDir"\*.*" -include *.zip -Name | %{$ZipFileName+="$_,"};
# �����̃J���}���O��
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "���M�Ώۃt�@�C����= $ZipFileName";

return "$ZipFileName";
