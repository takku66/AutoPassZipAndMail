# 実行フォルダを取得
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# 実行ファイル名取得
$PsFileName = $MyInvocation.MyCommand.Name;

＃ ログファイル出力スクリプトを展開
. ".\\logger.ps1";

＃ JSONファイル読み込みスクリプトを展開
try{
	. ".\\read_json.ps1";
}catch{
	outLog "E" $_.Exception;
	exit 1;
}

# 引数を取得する
$ZipPass = $args[0];

# 現在の年を取得する
$MailYear = (Get-Date).Year;
# 前の年を取得する
$MailPreYear = ((Get-Date).AddYears(-1)).Year;
# 次の年を取得する
$MailNextYear = ((Get-Date).AddYears(+1)).Year;

# 現在月を取得する
$MailMonth = (Get-Date).Month;
# 前の月を取得する
$MailPreMonth = ((Get-Date).AddMonths(-1)).Month;
# 次の月を取得する
$MailNextMonth = ((Get-Date).AddMonths(+1)).Month;

# 本日日付を取得する
$MailDay = (Get-Date).Day;
# 前の日を取得する
$MailPreDay = ((Get-Date).AddDays(-1)).Day;
# 次の日を取得する
$MailNextDay = ((Get-Date).AddDays(+1)).Day;

$ZipTargetDir = $ZipJson.target_path;

$AttachmentFile="";

# 添付対象のファイル名を取得
Get-ChildItem ($ZipTargetDir + "\*.*") -include *.zip | %{$AttachmentFile+="file:///$_,"};
# 末尾のカンマを外す
$AttachmentFile = $AttachmentFile -replace ",$","";

# 送信対象のファイル名を取得
Get-ChildItem ($ZipTargetDir + "\*.*") -include *.zip -Name | %{$ZipFileName+="$_,"};
# 末尾のカンマを外す
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "添付ファイルを取得：[$AttachmentFile]";

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


outLog "I" "メール作成処理開始";
# メール送信文作成
for($MailCnt = 0; $MailCnt -lt $MailJson.mail.Count; $MailCnt++){
	
    try{
	    $MailContent = "";
	
        # contentの中身を全て読み込み
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
        outLog "E" "メール作成中のエラー。";
        outLog "E" (($MailCnt+1)+"通目");
        outLog "E" (($ContentCnt+1)+"行目");
        outLog "E" $_.Exception;
        exit 1;
    }
}
outLog "I" "メール作成処理終了";

exit 0;
