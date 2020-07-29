# 実行フォルダを取得
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;

# ログ出力用年月日
$Now = (Get-Date).ToString("yyyy/mm/dd hh:mm:ss ");

function outLog($logType, $logContent){
	
    if($Debug){
        Write-Debug "ログ出力： $logContent";
    }
    
    try{
	    if($logType -eq "E"){
	        "$Now Error  :  $logContent">>$CurrentDir\$Log;
	    }elseif($logType -eq "W"){
	        "$Now Warning:  $logContent">>$CurrentDir\$Log;
	    }elseif($logType -eq "I"){
	        "$Now Info   :  $logContent">>$CurrentDir\$Log;
	    }else{
	        "">>$CurrentDir\$Log;
	    }
	}catch{
		Write-Debug "ログ出力中のエラー：$_.Exception";
		"$Now Error  :  $_.Exception">>$CurrentDir\$Log;
		exit 1;
	}

}

