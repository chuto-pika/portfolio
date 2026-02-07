require "test_helper"

class MessageGeneratorTest < ActiveSupport::TestCase
  setup do
    @recipient_parent = Recipient.find_or_create_by!(name: "親", position: 1)
    @recipient_partner = Recipient.find_or_create_by!(name: "パートナー", position: 2)
    @recipient_friend = Recipient.find_or_create_by!(name: "友人", position: 3)
    @recipient_sibling = Recipient.find_or_create_by!(name: "兄弟・姉妹", position: 4)
    @recipient_grandparent = Recipient.find_or_create_by!(name: "祖父母", position: 5)
    @recipient_colleague = Recipient.find_or_create_by!(name: "職場の人", position: 6)
    @recipient_other = Recipient.find_or_create_by!(name: "その他", position: 7)

    @occasion_birthday = Occasion.find_or_create_by!(name: "誕生日・記念日", position: 1)
    @occasion_thanks = Occasion.find_or_create_by!(name: "日頃の感謝", position: 2)
    @occasion_helped = Occasion.find_or_create_by!(name: "最近助けてもらった", position: 3)
    @occasion_apart = Occasion.find_or_create_by!(name: "しばらく会えていない", position: 4)
    @occasion_noreason = Occasion.find_or_create_by!(name: "特別な理由はない", position: 5)
    @occasion_other = Occasion.find_or_create_by!(name: "その他", position: 6)

    @impression1 = Impression.find_or_create_by!(name: "いつも支えてくれる", position: 1)
    @impression2 = Impression.find_or_create_by!(name: "一緒にいると安心する", position: 2)
    @impression3 = Impression.find_or_create_by!(name: "笑顔にしてくれる", position: 3)

    @feeling_thanks = Feeling.find_or_create_by!(name: "ありがとう", position: 1)
    @feeling_yoroshiku = Feeling.find_or_create_by!(name: "これからもよろしく", position: 2)
    @feeling_tasukaru = Feeling.find_or_create_by!(name: "いつも助かっている", position: 3)
    @feeling_taisetsu = Feeling.find_or_create_by!(name: "大切に思っている", position: 4)
    @feeling_gomenne = Feeling.find_or_create_by!(name: "ごめんね、そしてありがとう", position: 5)
  end

  def build_message(recipient: nil, occasion: nil, feeling: nil, impressions: [], episode: nil, additional_message: nil)
    msg = Message.create!(
      recipient: recipient || @recipient_parent,
      occasion: occasion || @occasion_thanks,
      feeling: feeling || @feeling_thanks,
      episode: episode,
      additional_message: additional_message
    )
    impressions.each { |imp| msg.impressions << imp }
    msg
  end

  # --- 基本動作 ---

  test "generateでメッセージ文字列が生成される" do
    message = build_message(impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_kind_of String, result
    assert_predicate result, :present?
  end

  # --- recipient に応じた呼称 ---

  test "親の場合はお父さん・お母さんへの呼称が含まれる" do
    message = build_message(recipient: @recipient_parent, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
  end

  test "パートナーの場合はあなたへの呼称が含まれる" do
    message = build_message(recipient: @recipient_partner, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/あなたへ/, result)
  end

  test "友人の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_friend, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつもありがとうへ/, result)
  end

  test "祖父母の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_grandparent, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/おじいちゃん・おばあちゃんへ/, result)
  end

  test "職場の人の場合の呼称が含まれる" do
    message = build_message(recipient: @recipient_colleague, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつもお世話になっていますへ/, result)
  end

  test "その他の場合は呼称なしで始まる" do
    message = build_message(recipient: @recipient_other, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_no_match(/へ\n/, result)
  end

  # --- occasion に応じた導入文 ---

  test "誕生日・記念日の導入文が生成される" do
    message = build_message(occasion: @occasion_birthday, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/特別な日に/, result)
  end

  test "日頃の感謝の導入文が生成される" do
    message = build_message(occasion: @occasion_thanks, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/改めて気持ちを伝えたく/, result)
  end

  test "最近助けてもらったの導入文が生成される" do
    message = build_message(occasion: @occasion_helped, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/助けてもらったことがあって/, result)
  end

  test "しばらく会えていないの導入文が生成される" do
    message = build_message(occasion: @occasion_apart, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/しばらく会えていないけれど/, result)
  end

  test "特別な理由はないの導入文が生成される" do
    message = build_message(occasion: @occasion_noreason, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/特別な理由はないけれど/, result)
  end

  test "その他のoccasionの導入文が生成される" do
    message = build_message(occasion: @occasion_other, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/伝えたい気持ちがあって/, result)
  end

  # --- impressions ---

  test "impression1つの場合は自然な文章になる" do
    message = build_message(impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつも支えてくれる、そんな存在です。/, result)
  end

  test "impression2つの場合は自然に結合される" do
    message = build_message(impressions: [@impression1, @impression2])
    result = MessageGenerator.new(message).generate

    assert_match(/いつも支えてくれる、そして一緒にいると安心する。そんな存在です。/, result)
  end

  test "impression3つの場合は自然に結合される" do
    message = build_message(impressions: [@impression1, @impression2, @impression3])
    result = MessageGenerator.new(message).generate

    assert_match(/いつも支えてくれる、一緒にいると安心する、そして笑顔にしてくれる。そんな存在です。/, result)
  end

  test "impressionが0個の場合は印象セクションが含まれない" do
    message = build_message(impressions: [])
    result = MessageGenerator.new(message).generate

    assert_no_match(/そんな存在です/, result)
  end

  # --- episode ---

  test "エピソードが含まれる" do
    message = build_message(impressions: [@impression1], episode: "先日、体調を崩したときにそばにいてくれました。")
    result = MessageGenerator.new(message).generate

    assert_match(/先日、体調を崩したときにそばにいてくれました。/, result)
  end

  test "エピソードが空の場合はエピソードセクションが含まれない" do
    message = build_message(impressions: [@impression1], episode: nil)
    result = MessageGenerator.new(message).generate

    # 導入文 + 印象 + 締めのみ
    assert_match(/お父さん・お母さんへ/, result)
    assert_match(/そんな存在です/, result)
  end

  # --- feeling ---

  test "ありがとうの締めくくりが生成される" do
    message = build_message(feeling: @feeling_thanks, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/本当にありがとう/, result)
  end

  test "これからもよろしくの締めくくりが生成される" do
    message = build_message(feeling: @feeling_yoroshiku, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/これからもよろしくね/, result)
  end

  test "いつも助かっているの締めくくりが生成される" do
    message = build_message(feeling: @feeling_tasukaru, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/いつも本当に助かっています/, result)
  end

  test "大切に思っているの締めくくりが生成される" do
    message = build_message(feeling: @feeling_taisetsu, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/大切に思っています/, result)
  end

  test "ごめんね、そしてありがとうの締めくくりが生成される" do
    message = build_message(feeling: @feeling_gomenne, impressions: [@impression1])
    result = MessageGenerator.new(message).generate

    assert_match(/ごめんね。そして、いつもありがとう/, result)
  end

  # --- additional_message ---

  test "追加メッセージがある場合はP.S.として追加される" do
    message = build_message(impressions: [@impression1], additional_message: "今度ご飯行こうね！")
    result = MessageGenerator.new(message).generate

    assert_match(/P\.S\. 今度ご飯行こうね！/, result)
  end

  test "追加メッセージがない場合はP.S.が含まれない" do
    message = build_message(impressions: [@impression1], additional_message: nil)
    result = MessageGenerator.new(message).generate

    assert_no_match(/P\.S\./, result)
  end

  # --- 組み合わせテスト ---

  test "全要素を含むメッセージが正しく生成される" do
    message = build_message(
      recipient: @recipient_parent,
      occasion: @occasion_birthday,
      feeling: @feeling_thanks,
      impressions: [@impression1, @impression2],
      episode: "いつも応援してくれてありがとう。",
      additional_message: "また帰るね。"
    )
    result = MessageGenerator.new(message).generate

    assert_match(/お父さん・お母さんへ/, result)
    assert_match(/特別な日に/, result)
    assert_match(/いつも支えてくれる、そして一緒にいると安心する/, result)
    assert_match(/いつも応援してくれてありがとう。/, result)
    assert_match(/本当にありがとう/, result)
    assert_match(/P\.S\. また帰るね。/, result)
  end

  test "recipientとoccasionの異なる組み合わせで導入文が変化する" do
    msg1 = build_message(recipient: @recipient_partner, occasion: @occasion_birthday, impressions: [@impression1])
    msg2 = build_message(recipient: @recipient_partner, occasion: @occasion_apart, impressions: [@impression1])

    result1 = MessageGenerator.new(msg1).generate
    result2 = MessageGenerator.new(msg2).generate

    assert_match(/特別な日に/, result1)
    assert_match(/しばらく会えていないけれど/, result2)
    # 両方にパートナーの呼称が含まれる
    assert_match(/あなたへ/, result1)
    assert_match(/あなたへ/, result2)
  end
end
