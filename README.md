# 戯書1期データ小屋　解析プログラム
戯書1期データ小屋は[戯書](http://lisge.com/)（サイト消滅によりリンク先は製作者様サイト）を解析して得られるデータを扱った情報サイトです。  
このプログラムは戯書1期データ小屋で実際に使用している解析・DB登録プログラムです。  
データ小屋の表示部分については[別リポジトリ](https://github.com/white-mns/teiki_arcive_parse/tree/tawa_1)を参照ください。

# サイト
実際に動いているサイトです。  
[戯書1期データ小屋](https://data.teiki.org/tawa_1)

# 動作環境
以下の環境での動作を確認しています  
  
OS:CentOS release 6.5 (Final)  
DB:MySQL  
Perl:5.10.1  

## 必要なもの

bashが使えるLinux環境。（Windowsで処理を行う場合、execute.shの処理を手動で行ってください）  
perlが使える環境  
デフォルトで入ってないモジュールを使ってるので、

    cpan DateTime

みたいにCPAN等を使ってDateTimeやHTML::TreeBuilderといった足りないモジュールをインストールしてください。

## 使い方
圧縮ファイルを`data/orig`に置きます。

第一回更新なら

    ./execute.sh 1

とします。
最更新が1回あって圧縮ファイルが`002.zip`、`002_1.zip`となっている場合、その数字に合わせて

    ./execute.sh 2 0
    ./execute.sh 2 1

とすることで再更新前、再更新後を指定することが出来ます。
（ただし、データ小屋では仕様上、再更新前、再更新後のデータを同時に登録しないようにしています）  
上手く動けばoutput内に中間ファイルcsvが生成され、指定したDBにデータが登録されます。  
`ConstData.pm`及び`ConstData_Upload.pm`を書き換えることで、処理を実行する項目を制限できます。

    ./_execute_all.sh 1 5

とすると、第1回更新結果から第5回更新結果までの確定結果を再解析します。

## DB設定
`source/DbSetting.pm`にサーバーの設定を記述します。  
DBのテーブルは[Railsアプリ側](https://github.com/white-mns/teiki_arcive_parse/tree/tawa_1)で`rake db:migrate`して作成しています。

## 中間ファイル
DBにアップロードしない場合、固有名詞を数字で置き換えている箇所があるため、csvファイルを読むのは難しいと思います。

    $$common_datas{ProperName}->GetOrAddId($$data[2])

のような`GetorAddId`、`GetId`関数で変換していますので、似たような箇所を全て

    $$data[2]

のように中身だけに書き換えることで元の文字列がcsvファイルに書き出され読みやすくなります。

## ライセンス
本ソフトウェアはMIT Licenceを採用しています。 ライセンスの詳細については`LICENSE`ファイルを参照してください。
