# 実行フォルダを取得
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;
# 実行ファイル名取得
$PsFileName = $MyInvocation.MyCommand.Name;


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
    
}catch{
	
    throw $_.Exception;
}

