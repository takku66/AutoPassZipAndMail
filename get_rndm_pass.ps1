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
    outLog "E" "Json�t�@�C���̓ǂݍ��ݒ��̃G���[�B";
    outLog "E" $_.Exception;
}


# ����
$PassLen = $PassJson.pass_length;

function downloadPassFromWeb($PassLen) {

    $WebDriver = $SystemJson.web_driver;
    $DriverSupport = $SystemJson.driver_support;
    $Selenium = $SystemJson.selenium;
    $DriverType = $SystemJson.driver_type;


    # �����ŃE�F�u�𓮂������߂̐ݒ�
    Add-Type -Path $WebDriver;
    Add-Type -Path $DriverSupport;
    Add-Type -Path $Selenium;

    if($DriverType -eq "edge"){
        try{
            $BrowseDriver = $SystemJson.edge_driver;
        }catch{
            outLog "E" "�G�b�W�h���C�o�[�ǂݍ��ݒ��̃G���[�B";
            outLog "E" $_Exception;
        }
    }elseif($DriverType -eq "chrome"){
        try{
            $BrowseDriver = $SystemJson.chrome_driver;
	        $driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($BrowseDriver);
        }catch{
            outLog "E" "�N���[���h���C�o�[�ǂݍ��ݒ��̃G���[�B";
            outLog "E" $_Exception;
        }
    }


    # �p�X���[�h�擾�p��URL��ݒ�
    $driver.Url = $PassJson.url;

    # �T�C�g�̒��̃^�C�g������v����܂ő҂�
    do
    {
      Start-Sleep -s 1
      $title = $driver.Title;
    } until($title.Contains($PassJson.wait_title))
    outLog "I" "�ڑ������F[$PassJson.url]";


    outLog "I" "Javascript���s";
    # �T�C�g��Javascript�����s����
    $driver.ExecuteScript(
	    '
	    // �p�X���[�h���x�擾
	    var elmStrength = document.getElementById("Disable2");
	    // �p�X���[�h���x�̃`�F�b�N���u�ŋ��Ɂv
	    elmStrength.checked = "checked";
	
	    // �������擾
	    var elmRdDigit = document.getElementById("Digit0");
	    elmRdDigit.checked = "checked";
	    // ���������͗��擾
	    var elmsTxtDigit = document.getElementsByName("digit_s");
	    elmsTxtDigit[0].value = arguments[0];

	    // �p�X���[�h�������擾
	    var elmRdCnt = document.getElementById("Su0");
	    elmRdCnt.checked = "checked";
	    // ���������͎擾
	    var elmsTxtCnt = document.getElementsByName("su_s");
	    elmsTxtCnt[0].value = "1";

	    var elmsBtnSubmit = document.getElementsByClassName("btn_form btn_submit");
	    elmsBtnSubmit[0].click();
	    '
    , $PassLen);

    Start-Sleep -s 1

    # �܂��҂�
    do
    {
      Start-Sleep -s 1
      $title = $driver.Title;
    } until($title.Contains($PassJson.wait_title))

    Start-Sleep -s 1

    outLog "I" "�p�X���[�h�擾";
    # �p�X���[�h�������ʂ��擾����
    $divRndm = $driver.FindElementsByClassName('randam_gene_block');
    $lblRndmPass = $divRndm[0].FindElementsByClassName('form_txt');

    $ZipPass = $lblRndmPass[0].GetAttribute("value");

    $driver.Close();
    $driver.Dispose();

    outLog "I" "�p�X���[�h�擾�����I��";
    return $ZipPass;
}

function generatePass($PassLen) {
    
    outLog "I" "�p�X���[�h�����J�n";
    $length = $PassLen-1;

    $letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray();
    $uppers = "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray();
    $lowers = "abcdefghijkmnopqrstuvwxyz".ToCharArray();
    $digits = "23456789".ToCharArray();
    $symbols = "_-+=@$%".ToCharArray();

    $chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789_-+=@$%".ToCharArray();

    do {
        $pwdChars = "".ToCharArray();
        $goodPassword = $false;
        $hasDigit = $false;
        $hasSymbol = $false;
        $pwdChars += (Get-Random -InputObject $uppers -Count 1);
        for ($i=1; $i -lt $length; $i++) {
            $char = Get-Random -InputObject $chars -Count 1;
            if ($digits -contains $char) { $hasDigit = $true };
            if ($symbols -contains $char) { $hasSymbol = $true };
            $pwdChars += $char;
        }
        $pwdChars += (Get-Random -InputObject $lowers -Count 1);
        $password = $pwdChars -join "";
        $goodPassword = $hasDigit -and $hasSymbol;
    } until ($goodPassword)

    outLog "I" "�p�X���[�h�����I��";

    $password
    return $password;
}



if($PassJson.web_or_logic -eq "web"){
    try{
        $ZipPass = downloadPassFromWeb $PassLen;
    }catch{
        outLog "E" "�E�F�u�ł̃p�X���[�h�擾���̃G���[�B";
        outLog "E" $_.Exception;
    }
        
}elseif($PassJson.web_or_logic -eq "logic"){
    try{
        $ZipPass = generatePass $PassLen;
    }catch{
        outLog "E" "�p�X���[�h�������̃G���[�B";
        outLog "E" $_.Exception;
    }
}


if($PassJson.clip_board){
    Set-Clipboard -Value $ZipPass[($ZipPass.Count-1)];
}

return $ZipPass[($ZipPass.Count-1)];
