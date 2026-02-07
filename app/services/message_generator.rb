class MessageGenerator
  HONORIFICS = {
    "親" => "お父さん・お母さん",
    "パートナー" => "あなた",
    "友人" => "いつもありがとう",
    "兄弟・姉妹" => "お兄ちゃん・お姉ちゃん",
    "祖父母" => "おじいちゃん・おばあちゃん",
    "職場の人" => "いつもお世話になっています"
  }.freeze

  OCCASION_TEMPLATES = {
    "誕生日・記念日" => "特別な日に、普段なかなか言えない気持ちを伝えたくて書いています。",
    "日頃の感謝" => "いつも当たり前のように過ごしているけれど、改めて気持ちを伝えたくなりました。",
    "最近助けてもらった" => "最近、助けてもらったことがあって、ちゃんとお礼を伝えたいと思いました。",
    "しばらく会えていない" => "しばらく会えていないけれど、ふと気持ちを伝えたくなりました。",
    "特別な理由はない" => "特別な理由はないけれど、ふと気持ちを伝えたくなりました。"
  }.freeze

  FEELING_TEMPLATES = {
    "ありがとう" => "本当にありがとう。この気持ちが届くといいな。",
    "これからもよろしく" => "これからもよろしくね。一緒に過ごせる時間を大切にしたいです。",
    "いつも助かっている" => "いつも本当に助かっています。あなたがいてくれることが、私の支えです。",
    "大切に思っている" => "あなたのことを大切に思っています。これからもずっと。",
    "ごめんね、そしてありがとう" => "素直になれないこともあるけれど、ごめんね。そして、いつもありがとう。"
  }.freeze

  def initialize(message)
    @message = message
    @recipient = message.recipient
    @occasion = message.occasion
    @impressions = message.impressions
    @feeling = message.feeling
    @episode = message.episode
    @additional_message = message.additional_message
  end

  def generate
    parts = []
    parts << opening
    parts << impression_section
    parts << @episode if @episode.present?
    parts << closing
    parts << "P.S. #{@additional_message}" if @additional_message.present?
    parts.compact.join("\n\n")
  end

  private

  def opening
    hon = HONORIFICS[@recipient.name]
    prefix = hon ? "#{hon}へ\n\n" : ""
    body = OCCASION_TEMPLATES.fetch(@occasion.name, "伝えたい気持ちがあって、書いています。")
    "#{prefix}#{body}"
  end

  def impression_section
    return nil if @impressions.empty?

    names = @impressions.map(&:name)
    if names.size == 1
      "#{names.first}、そんな存在です。"
    else
      "#{names[0..-2].join("、")}、そして#{names.last}。そんな存在です。"
    end
  end

  def closing
    FEELING_TEMPLATES.fetch(@feeling.name, "ありがとう。")
  end
end
