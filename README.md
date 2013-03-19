# rubyプロセスサイズ(RSS)膨張の調査

## 現象

* fluentd + ruby 2.0.0-p0 を使っているとプロセスの RSS がひたすら増える
  * jemalloc と組み合わせると更に不審な症状を示す
  * 参照: http://d.hatena.ne.jp/tagomoris/20130315/1363336770
* CentOS6.4 (kernel 2.6.32-358) + glibc 2.12-1 で確認
* OSX Leopard (10.7.5) で確認

CentOS6.4 + ruby 2.0.0-p0 で30分稼動時、プロセスサイズ約8GBの時の GC.stat および ObjectSpace.count_objects の状態

```ruby
{:count_objects=>
  {:TOTAL=>16678344,
   :FREE=>13879795,
   :T_OBJECT=>452,
   :T_CLASS=>1681,
   :T_MODULE=>120,
   :T_FLOAT=>9,
   :T_STRING=>1200787,
   :T_REGEXP=>360,
   :T_ARRAY=>400455,
   :T_HASH=>390434,
   :T_STRUCT=>46,
   :T_BIGNUM=>80,
   :T_FILE=>23,
   :T_DATA=>15190,
   :T_MATCH=>1,
   :T_COMPLEX=>1,
   :T_RATIONAL=>49,
   :T_NODE=>788692,
   :T_ICLASS=>169},
 :gc_stat=>
  {:count=>498,
   :heap_used=>41324,
   :heap_length=>98242,
   :heap_increment=>25813,
   :heap_live_num=>523143284,
   :heap_free_num=>16630921,
   :heap_final_num=>0,
   :total_allocated_object=>1632053646,
   :total_freed_object=>1108910362}}
```

## 環境

以下のプロセスを準備する必要がある。

 * counter (fluentd -c counter.conf)
   * 最終的なfluentdメッセージを受け取り先として立てておく
   * 単にデータの流出先として必要なだけ
 * deliver (fluentd -c deliver2.conf)
   * ネットワーク経由でメッセージを受け取り、それを counter に転送する
   * こいつのプロセスサイズが膨張する
 * forward_bench.rb
   * deliver に対してネットワーク経由でデータを送り付けるスクリプト

これらを動かした状態で ps auxww 等で deliver プロセス(2プロセス上がるうちの実働プロセスのほう)のRSSを観察すると膨れていく様子が見える。

## 再現方法

セットアップ

```sh
ruby -v
# ruby 2.0.0p0 (2013-02-24 revision 39474) [x86_64-linux]
git clone git://github.com/tagomoris/fluentd-leak-test.git
cd fluentd-leak-test
bundle install --path vendor
```

counterの起動 (port 24225)

```sh
bundle exec fluentd -c counter.conf
```

deliverの起動 (port 24224)

```sh
bundle exec fluentd -c deliver2.conf
```

なお以下のようにして起動すれば GC.stat と ObjectSpace.count_objects の結果をダンプしながら観察できる

```sh
bundle exec fluentd -r './dumpstat' -c deliver2.conf
```

fluentdプロセスが上がった状態でベンチスクリプトを起動すると30分走行する。

```sh
ruby forward_bench.rb
```

### 注意点

* jemallocを使用する場合はコマンド起動時に以下のようにする
```
bundle exec je fluentd ....
```

* rubyのバージョンを切り替えるとき
  * vendor ディレクトリおよび .bundle ディレクトリをいちど削除する
  * 再度 bundle install --path vendor する

## ご連絡

Twitter: @tagomoris
