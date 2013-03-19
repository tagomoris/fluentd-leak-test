require 'msgpack'
require 'socket'

SECONDS = 1800

TESTTAG = 'testdata.bench'

LINES_PER_SEND = 10000 # 200,000 lines/1s
SEND_PER_SECONDS = 20.0 # 0.05 sec interval

TARGET_HOST = 'localhost'
TARGET_PORT = 24224

LOGS = <<EOL
203.0.113.101 - - [14/Mar/2013:07:51:30 +0900] "GET /xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resize/240x999/http://livedoor.example.jp/thisismyblog/imgs/x/x/xxxxxxx.jpg HTTP/1.1" 200 15773 "-" "-" "-" resize.example.jp 0.003
203.0.113.1 - - [14/Mar/2013:07:51:30 +0900] "GET /xxxxxxxxxx/resize/240x999/http://livedoor.example.jp/thisismyblog/imgs/x/x/xxxxxxx.jpg HTTP/1.1" 200 15773 "-" "-" "-" resize.example.jp 0.003
203.0.113.1 - - [14/Mar/2013:07:51:30 +0900] "GET /x/resize/240x999/http://livedoor.example.jp/thisismyblog/imgs/x/x/xxxxxxx.jpg HTTP/1.1" 200 15773 "-" "-" "-" resize.example.jp 0.003
203.0.113.1 - - [14/Mar/2013:07:51:30 +0900] "GET /x/resize/240x999/http://livedoor.example.jp/thisismyblog/imgs/x/x/xx.jpg HTTP/1.1" 200 15773 "-" "-" "-" resize.example.jp 0.003
203.0.113.1 - - [14/Mar/2013:07:51:30 +0900] "GET /x/resize/240x99/http://livedoor.example.jp/thisismyblog/imgs/x/x/x.jpg HTTP/1.1" 200 15773 "-" "-" "-" resize.example.jp 0.003
EOL
LOGLINES = LOGS.split(/\n/).map(&:chomp)

$message = nil
def msg(tag, time, num, logs)
  return $message if $message
  event_stream = ''
  (num / logs.size).times do |n|
    logs.each do |line|
      event_stream += MessagePack.pack([time, {'message' => line}])
    end
  end
  $message = MessagePack.pack([tag, event_stream]);
end

def main
  starts = Time.now.to_i
  ends = starts + SECONDS
  interval = 1.0 / SEND_PER_SECONDS

  sock = TCPSocket.open(TARGET_HOST, TARGET_PORT)
  while Time.now.to_i < ends
    sock.write(msg(TESTTAG, starts, LINES_PER_SEND, LOGLINES))
    sleep interval
  end
end

main
