require 'bundler/setup'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'date'
require 'dotenv'
require 'slack-ruby-client'

Dotenv.load

APPLICATION_NAME = 'Google Calendar × Slack'.freeze # そこまで重要ではないので適当な名前でOK。
CREDENTIALS_PATH = './credentials.json'.freeze # サービスアカウント作成時にDLしたJSONファイルをリネームしてルートディレクトリに配置。
CALENDER_ID = ENV['CALENDER_ID'].freeze # Googleカレンダー設定ページの「カレンダーの統合」という項目内に記載されている。

class GoogleCalendar
  def initialize
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
    @calendar_id = CALENDER_ID
  end
  
  # 認証。
  def authorize
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(CREDENTIALS_PATH),
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY
    )
    authorizer.fetch_access_token!
    authorizer
  end
  
  # 引数に渡した日付をもとに予定一覧を取得。
  def fetch_events(date)
    @service.list_events(
      @calendar_id,
      max_results: 10, # 取得する予定の最大数。
      single_events: true,
      order_by: 'startTime',
      time_min: "#{date}T00:00:00Z", # 取得を開始するタイミング
      time_max: "#{date}T23:59:59Z"  # 取得を終了するタイミング
    )
  end
end

def create_slack_message
  google_calender = GoogleCalendar.new
  events = google_calender.fetch_events(Date.today)
  
  # その日の予定が何も無かった場合はここで処理終了。
  if events.items.empty?
    puts '本日の予定はありません。'
    return
  end
  
  event_list = ''

  events.items.each_with_index do |event, index|
    start_time = event.start.date || event.start.date_time
    end_time = event.end.date || event.end.date_time
  
    event_details = "* #{event.summary} (#{start_time.strftime('%H:%M')} ~ #{end_time.strftime('%H:%M')})"
    event_details << " #{event.hangout_link}" if event.hangout_link # もしGoogleハングアウトのURLがある場合はそれも拾う。
    event_details << "\n\n" unless index == events.items.size - 1

    event_list << event_details
  end
  
  # ↑で取得した予定をメッセージの形に整形する。
  message = <<~EOS
    本日の予定です！
  
    ```
    #{event_list}
    ```
  EOS
end

# Slack通知を行うための初期設定。
Slack.configure do |conf|
  conf.token = ENV['SLACK_BOT_TOKEN']
end

def post_to_slack
  message = create_slack_message
  
  client = Slack::Web::Client.new
  client.chat_postMessage(
    channel: ENV['SLACK_CHANNEL_NAME'], # 通知を飛ばしたいSlackチャンネルを指定。
    text: message, 
    as_user: true
  )
end

post_to_slack
