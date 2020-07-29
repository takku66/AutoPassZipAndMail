# ���s�t�H���_���擾
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# ���s�t�@�C�����擾
$PsFileName = $MyInvocation.MyCommand.Name;


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
    
}catch{
	
    throw $_.Exception;
}

