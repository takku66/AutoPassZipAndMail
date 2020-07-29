# パス付きZIP & メール自動作成バッチ


## 動作確認環境
・OS:Windows10
・実行プログラム：コマンドプロンプト / Powershell
・ZIP化モジュール：Lhaplus
・メールサービス；Thunderbird


## 使用方法
1. 各Jsonファイルに、利用環境に合わせたパスを記載する。
2. main.batを実行する。


## 設定ファイルの説明
### system.json
・`web_driver`.`driver_support`,`selenium`,`driver_type`,`edge_driver`,`chrome_driver`
各ドライバーの格納パスを記載します。
（とあるサイトからパスワードを取得する場合のみ。※pass.jsonで詳解）

・`zip_module`
ZIP化するプログラムの格納先を記載します。

・`mail_program`
使用するメールサービスを指定します。

・`mail_program`
使用するメールサービスを指定します。

・`log_file`
ログの出力先を指定します。

・`debug_mode`
開発用に記載しています。
特に表示結果が変わることはありません。

### pass.json
・`web_or_logic`
パスワードの取得方法を指定します。（もろもろの事情で、とあるサイトを利用する設定を用意しています。）

・`pass_length`
パスワードの長さを指定します。

・`url`
とあるサイトのURLを記載します。

・`wait_title`
セレニウムでブラウザ表示した後、表示が完了したことを知らせるためにタイトル名を記載します。

・`clip_board`
パスワードをクリップボードに付与します。

### zip.json
・`target_path`
ZIP化対象のフォルダまでのパスを設定します。

・`target_file`
ZIP化対象とするファイルを指定します。（ワイルドカード有効）


### mail.json
・`mail`
配列で指定します。
作成したいメールの数だけ設定できます。
|プロパティ|説明|
|-----|-----|
|content|メールの送信内容を設定します。|
|toAddress|TOに設定するメールアドレスを指定します。|
|ccAddress|CCに設定するメールアドレスを指定します。|
|bccAddress|BCCに設定するメールアドレスを指定します。|
|subject|タイトルに設定する文言を指定します。|
|attachment|添付ファイルを指定します。|


・`mail_options`
メールをコマンド実行する場合に指定するオプションを記載します。

#### mail.json内で扱える変数について
mail.jsonでは、変数を使用することができます。

|変数|説明|
|-----|-----|
|$\_\_MailYear\_\_|現在年|
|$\_\_MailPreYear\_\_|前年|
|$\_\_MailNextYear\_\_|翌年|
|$\_\_MailMonth\_\_|現在月|
|$\_\_MailPreMonth\_\_|前月|
|$\_\_MailNextMonth\_\_|次月|
|$\_\_MailDay\_\_|現在日|
|$\_\_MailPreDay\_\_|前日|
|$\_\_MailNextDay\_\_|翌日|
|$\_\_AttachmentFile\_\_|ZIP化したファイルの添付用文字列|
|$\_\_ZipFileName\_\_|ZIP化したファイルのファイル名|
|$\_\_ZipPass\_\_|ZIP化した時のパスワード|
|$\_\_toAddress\_\_|toAddressに指定したメールアドレス|
|$\_\_ccAddress\_\_|ccAddressに指定したメールアドレス|
|$\_\_bccAddress\_\_|bccAddressに指定したメールアドレス|
|$\_\_subject\_\_|subjectに設定した文字列|
|$\_\_attachment\_\_|メール添付用の文字列（ftp文字列）|
|$\_\_content\_\_|contentに指定した文字列|


## 補足
・他のZIP化プログラムや、メールサービスでは試したことがありません・・・



