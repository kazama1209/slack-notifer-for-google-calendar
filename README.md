# slack-notifer-for-google-calendar

API経由でGoogleカレンダーから予定を取得し、Slack通知を飛ばす事ができるプログラム。

<img width="663" alt="スクリーンショット 2021-02-06 12 36 15" src="https://user-images.githubusercontent.com/51913879/107111391-211d9480-6893-11eb-8bdc-dcd5e6ecae37.png">

## セットアップ

- Rubyのバージョンを指定
```
$ rbenv local 2.5.1
```

- gemをインストール
```
$ bundle install --path vendor/bundle
```

- 環境変数をセット
```
cp .env.sample .env
```
```
# ./.env

CALENDER_ID=
SLACK_BOT_TOKEN=
SLACK_CHANNEL_NAME=
```
それぞれ適宜入力。

- 実行
```
$ bundle exec ruby app.rb
```

## 備考

Google APIを使用するための設定や認証情報などの取得方法に関してはQiitaに詳しい記事を書いているのでそちらを参照。

[【Ruby】Googleカレンダーから予定を取得してSlack通知を飛ばしてみる](https://qiita.com/kazama1209/items/a9be845f80a5d7dc59ba)





