# 実行フォルダを取得
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# 実行ファイル名取得
$PsFileName = $MyInvocation.MyCommand.Name;

# JSONファイル読み込みスクリプトを展開
try{
	. ".\\read_json.ps1";
	# ログファイル出力スクリプトを展開
	. ".\\logger.ps1";

}catch{
	outLog "E" $_.Exception;
	exit 1;
}



# 桁数
$PassLen = $PassJson.passLength;

function downloadPassFromWeb($PassLen) {

    $WebDriver = $SystemJson.web_driver;
    $DriverSupport = $SystemJson.driver_support;
    $Selenium = $SystemJson.selenium;
    $DriverType = $SystemJson.driver_type;


    # 自動でウェブを動かすための設定
    Add-Type -Path $WebDriver;
    Add-Type -Path $DriverSupport;
    Add-Type -Path $Selenium;

    if($DriverType -eq "edge"){
        try{
            $BrowseDriver = $SystemJson.edge_driver;
        }catch{
            outLog "E" "エッジドライバー読み込み中のエラー。";
            outLog "E" $_Exception;
            exit 1;
        }
    }elseif($DriverType -eq "chrome"){
        try{
            $BrowseDriver = $SystemJson.chrome_driver;
	        $driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($BrowseDriver);
        }catch{
            outLog "E" "クロームドライバー読み込み中のエラー。";
            outLog "E" $_Exception;
            exit 1;
        }
    }


    # パスワード取得用のURLを設定
    $driver.Url = $PassJson.url;

    # サイトの中のタイトルが一致するまで待つ
    do
    {
      Start-Sleep -s 1
      $title = $driver.Title;
    } until($title.Contains($PassJson.waitTitle))
    outLog "I" "接続成功：[$PassJson.url]";


    outLog "I" "Javascript実行";
    # サイトにJavascriptを実行する
    $driver.ExecuteScript(
	    '
	    // パスワード強度取得
	    var elmStrength = document.getElementById("Disable2");
	    // パスワード強度のチェックを「最強に」
	    elmStrength.checked = "checked";
	
	    // 文字数取得
	    var elmRdDigit = document.getElementById("Digit0");
	    elmRdDigit.checked = "checked";
	    // 文字数入力欄取得
	    var elmsTxtDigit = document.getElementsByName("digit_s");
	    elmsTxtDigit[0].value = arguments[0];

	    // パスワード生成数取得
	    var elmRdCnt = document.getElementById("Su0");
	    elmRdCnt.checked = "checked";
	    // 生成数入力取得
	    var elmsTxtCnt = document.getElementsByName("su_s");
	    elmsTxtCnt[0].value = "1";

	    var elmsBtnSubmit = document.getElementsByClassName("btn_form btn_submit");
	    elmsBtnSubmit[0].click();
	    '
    , $PassLen);

    Start-Sleep -s 1

    # また待つ
    do
    {
      Start-Sleep -s 1
      $title = $driver.Title;
    } until($title.Contains($PassJson.waitTitle))

    Start-Sleep -s 1

    outLog "I" "パスワード取得";
    # パスワード生成結果を取得する
    $divRndm = $driver.FindElementsByClassName('randam_gene_block');
    $lblRndmPass = $divRndm[0].FindElementsByClassName('form_txt');

    $ZipPass = $lblRndmPass[0].GetAttribute("value");

    $driver.Close();
    $driver.Dispose();

    outLog "I" "パスワード取得処理終了";
    return $ZipPass;
}

function generatePass($PassLen) {
    
    outLog "I" "パスワード生成開始";
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

    outLog "I" "パスワード生成終了";

    $password
    return $password;
}

if($PassJson.webOrLogic -eq "web"){
    try{
        $ZipPass = downloadPassFromWeb $PassLen;
    }catch{
        outLog "E" "ウェブでのパスワード取得中のエラー。";
        outLog "E" $_.Exception;
        exit 1;
    }
        
}elseif($PassJson.webOrLogic -eq "logic"){
    try{
    	echo ロジックでのパスワード生成処理まで入っているよ
        $ZipPass = generatePass $PassLen;
    }catch{
        outLog "E" "パスワード生成中のエラー。";
        outLog "E" $_.Exception;
        exit 1;
    }
}


if($PassJson.clipBoard){
    Set-Clipboard -Value $ZipPass[($ZipPass.Count-1)];
}

echo $ZipPass[($ZipPass.Count-1)];
return $ZipPass[($ZipPass.Count-1)];

