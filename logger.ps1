# ���s�t�H���_���擾
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent;

# ���O�o�͗p�N����
$Now = (Get-Date).ToString("yyyy/mm/dd hh:mm:ss ");

function outLog($logType, $logContent){
	
    if($Debug){
        Write-Debug "���O�o�́F $logContent";
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
		Write-Debug "���O�o�͒��̃G���[�F$_.Exception";
		"$Now Error  :  $_.Exception">>$CurrentDir\$Log;
		exit 1;
	}

}

