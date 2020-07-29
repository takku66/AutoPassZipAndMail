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

# zip化モジュールを指定
$ZipProgram = $SystemJson.zip_module;

# zip対象のフォルダを指定
$ZipTargetDir = $ZipJson.target_path;

# zip対象のフォルダを指定
$ZipTargetFile = $ZipJson.target_file;

try{
	$ZipTargetFiles = @(Get-ChildItem ($ZipTargetDir + "\" + $ZipTargetFile) -Include *);
}catch{
	outLog "E" "zip化対象のファイル取得中にエラー。";
    outLog "E" $_.Exception;
    exit 1;
}

outLog "I" "zip化パラメータ取得成功";

# zip化
if($Debug){
	Write-host "Zip化モジュール= "$ZipProgram
	#Write-host "モジュール引数= "$ZipModuleArgs
	Write-host "Zip化対象フォルダ= "$ZipTargetDir
	Write-host "Zip化対象ファイル= "$ZipTargetFile
	Write-host "& $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$ZipTargetDir\$ZipTargetFile;"
}

try{
    foreach($zipFile in $ZipTargetFiles){
        #Start-Process $ZipProgram -ArgumentList /c:zip,/o:$ZipTargetDir,/p:$ZipPass,$zipFile;
        & "$ZipProgram" /c:zip /o:$ZipTargetDir /p:$ZipPass "$zipFile"
    }
        
}catch{
    outLog "E" "zip化中にエラー";
    outLog "E" $_.Exception;
    exit 1;
}
outLog "I" "zip化終了";

Start-Sleep -s 5


# 送信対象のファイル名を取得
Get-ChildItem $ZipTargetDir"\*.*" -include *.zip -Name | %{$ZipFileName+="$_,"};
# 末尾のカンマを外す
$ZipFileName = $ZipFileName -replace ",$","";

outLog "I" "送信対象ファイル名= $ZipFileName";

return "$ZipFileName";
