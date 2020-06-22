# 実行フォルダを取得
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# 実行ファイル名取得
$PsFileName = $MyInvocation.MyCommand.Name;

# ログ出力用年月日
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
    # 各JSONファイルを読み込み
    $SystemJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\system.json -Raw);
    $PassJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\pass.json -Raw);
    $ZipJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\zip.json -Raw);
    $MailJson = ConvertFrom-Json -InputObject (Get-Content $CurrentDir\json\mail.json -Raw);
    # ログファイル
    $Log = $SystemJson.log_file;
    # デバッグモード
    $Debug = $SystemJson.debug_mode;
    outLog "" "";
    outLog "I" "処理開始：[$PsFileName]";
}catch{
    outLog "E" "Jsonファイルの読み込み中にエラーが発生しました。";
    outLog "E" $_.Exception;
}

# 引数を取得する
$ZipPass = $args[0];

# zip化モジュールを指定
$ZipProgram = $SystemJson.zip_module;

# zip対象のフォルダを指定
$ZipTargetDir = $ZipJson.target_path;

# zip対象のフォルダを指定
$ZipTargetFile = $ZipJson.target_file;

$ZipTargetFiles = @(Get-ChildItem ($ZipTargetDir + "\" + $ZipTargetFile) -Include *);

outLog "I" "zip化パラメータ取得成功";

# zip化
if($Debug){
	Write-host "Zip化モジュール= "$ZipProgram
	#Write-host "モジュール引数= "$ZipModuleArgs
	Write-host "Zip化対象フォルダ= "$ZipTargetDir
	Write-host "Zip化対象ファイル= "$ZipTargetFile
	Write-host "Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$ZipTargetDir\$ZipTargetFile;"
}

try{
    foreach($zipFile in $ZipTargetFiles){
        #Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$zipFile;
        & "$ZipProgram" /c:zip /o:$ZipTargetDir /p:$ZipPass "$zipFile"
    }
        
}catch{
    outLog "E" "zip化中にエラー";
    outLog "E" $_.Exception;
}
outLog "I" "zip化終了";

Start-Sleep -s 5


# 送信対象のファイル名を取得
Get-ChildItem $ZipTargetDir"\*.*" -include *.zip -Name | %{$ZipFileName+="$_,"};
# 末尾のカンマを外す
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "送信対象ファイル名= $ZipFileName";

return "$ZipFileName";
