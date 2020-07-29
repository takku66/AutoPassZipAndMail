# ���s�t�H���_���擾
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# ���s�t�@�C�����擾
$PsFileName = $MyInvocation.MyCommand.Name;

�� ���O�t�@�C���o�̓X�N���v�g��W�J
. ".\\logger.ps1";

�� JSON�t�@�C���ǂݍ��݃X�N���v�g��W�J
try{
	. ".\\read_json.ps1";
}catch{
	outLog "E" $_.Exception;
	exit 1;
}

# �������擾����
$ZipPass = $args[0];

# zip�����W���[�����w��
$ZipProgram = $SystemJson.zip_module;

# zip�Ώۂ̃t�H���_���w��
$ZipTargetDir = $ZipJson.target_path;

# zip�Ώۂ̃t�H���_���w��
$ZipTargetFile = $ZipJson.target_file;

try{
	$ZipTargetFiles = @(Get-ChildItem ($ZipTargetDir + "\" + $ZipTargetFile) -Include *);
}catch{
	outLog "E" "zip���Ώۂ̃t�@�C���擾���ɃG���[�B";
    outLog "E" $_.Exception;
    exit 1;
}

outLog "I" "zip���p�����[�^�擾����";

# zip��
if($Debug){
	Write-host "Zip�����W���[��= "$ZipProgram
	#Write-host "���W���[������= "$ZipModuleArgs
	Write-host "Zip���Ώۃt�H���_= "$ZipTargetDir
	Write-host "Zip���Ώۃt�@�C��= "$ZipTargetFile
	Write-host "& $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$ZipTargetDir\$ZipTargetFile;"
}

try{
    foreach($zipFile in $ZipTargetFiles){
        #Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$zipFile;
        & "$ZipProgram" /c:zip /o:$ZipTargetDir /p:$ZipPass "$zipFile"
    }
        
}catch{
    outLog "E" "zip�����ɃG���[";
    outLog "E" $_.Exception;
    exit 1;
}
outLog "I" "zip���I��";

Start-Sleep -s 5


# ���M�Ώۂ̃t�@�C�������擾
Get-ChildItem $ZipTargetDir"\*.*" -include *.zip -Name | %{$ZipFileName+="$_,"};
# �����̃J���}���O��
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "���M�Ώۃt�@�C����= $ZipFileName";

return "$ZipFileName";
