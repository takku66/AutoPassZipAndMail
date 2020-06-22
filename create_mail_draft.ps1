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

# ���݂̔N���擾����
$MailYear = (Get-Date).Year;
# �O�̔N���擾����
$MailPreYear = ((Get-Date).AddYears(-1)).Year;
# ���̔N���擾����
$MailNextYear = ((Get-Date).AddYears(+1)).Year;

# ���݌����擾����
$MailMonth = (Get-Date).Month;
# �O�̌����擾����
$MailPreMonth = ((Get-Date).AddMonths(-1)).Month;
# ���̌����擾����
$MailNextMonth = ((Get-Date).AddMonths(+1)).Month;

# �{�����t���擾����
$MailDay = (Get-Date).Day;
# �O�̓����擾����
$MailPreDay = ((Get-Date).AddDays(-1)).Day;
# ���̓����擾����
$MailNextDay = ((Get-Date).AddDays(+1)).Day;

$ZipTargetDir = $ZipJson.target_path;

$AttachmentFile="";

# �Y�t�Ώۂ̃t�@�C�������擾
Get-ChildItem ($ZipTargetDir + "\*.*") -include *.zip | %{$AttachmentFile+="file:///$_,"};
# �����̃J���}���O��
$AttachmentFile = $AttachmentFile -replace ",$","";

# ���M�Ώۂ̃t�@�C�������擾
Get-ChildItem ($ZipTargetDir + "\*.*") -include *.zip -Name | %{$ZipFileName+="$_,"};
# �����̃J���}���O��
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "�Y�t�t�@�C�����擾�F[$AttachmentFile]";

function replaceVar($replaceStr){
    $replaceStr = $replaceStr -replace '\$__MailYear__',$MailYear;
    $replaceStr = $replaceStr -replace '\$__MailPreYear__',$MailPreYear;
    $replaceStr = $replaceStr -replace '\$__MailNextYear__',$MailNextYear;
    $replaceStr = $replaceStr -replace '\$__MailMonth__',$MailMonth;
    $replaceStr = $replaceStr -replace '\$__MailPreMonth__',$MailPreMonth;
    $replaceStr = $replaceStr -replace '\$__MailNextMonth__',$MailNextMonth;
    $replaceStr = $replaceStr -replace '\$__MailDay__',$MailDay;
    $replaceStr = $replaceStr -replace '\$__MailPreDay__',$MailPreDay;
    $replaceStr = $replaceStr -replace '\$__MailNextDay__',$MailNextDay;
    $replaceStr = $replaceStr -replace '\$__AttachmentFile__',$AttachmentFile;
    $replaceStr = $replaceStr -replace '\$__ZipFileName__',$ZipFileName;
	$replaceStr = $replaceStr -replace '\$__ZipPass__',$ZipPass;
    $replaceStr = $replaceStr -replace '\$__toAddress__',$toAddress;
    $replaceStr = $replaceStr -replace '\$__ccAddress__',$ccAddress;
    $replaceStr = $replaceStr -replace '\$__bccAddress__',$bccAddress;
    $replaceStr = $replaceStr -replace '\$__subject__',$subject;
    $replaceStr = $replaceStr -replace '\$__attachment__',$attachment;
    $replaceStr = $replaceStr -replace '\$__content__',$content;

    return $replaceStr;
}


outLog "I" "���[���쐬�����J�n";
# ���[�����M���쐬
for($MailCnt = 0; $MailCnt -lt $MailJson.mail.Count; $MailCnt++){
	
    try{
	    $MailContent = "";
	
        # content�̒��g��S�ēǂݍ���
	    for($ContentCnt = 0; $ContentCnt -lt $MailJson.mail[$MailCnt].content.Count; $ContentCnt++){
		
		    $MailContent += $MailJson.mail[$MailCnt].content[$ContentCnt];
		    $MailContent += "`r`n";
	    }
	
        $toAddress = $MailJson.mail[$MailCnt].toAddress;
        $ccAddress = $MailJson.mail[$MailCnt].ccAddress;
        $bccAddress = $MailJson.mail[$MailCnt].bccAddress;
        $subject = $MailJson.mail[$MailCnt].subject;
        $attachment = $MailJson.mail[$MailCnt].attachment;
        $content = $MailContent;
        $mailopts = $MailJson.mail_options;
	
        $subject = replaceVar($subject);
        $attachment = replaceVar($attachment);
        $content = replaceVar($content);
        
        $RtnStr += $content ;
    
        $mailopts = replaceVar($mailopts);

        Start-Process $SystemJson.mail_program -ArgumentList $mailopts;

	    if($Debug){
            $content>$CurrentDir\mail$MailCnt.txt;
	    }
    }catch{
        outLog "E" "���[���쐬���̃G���[�B";
        outLog "E" (($MailCnt+1)+"�ʖ�");
        outLog "E" (($ContentCnt+1)+"�s��");
        outLog "E" $_.Exception;
    }
}
outLog "I" "���[���쐬�����I��";

return 0;
