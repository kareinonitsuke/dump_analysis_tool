# ダンプデータの整形ツール

class StatusFromDumpstr
  # TODO:
  # headerとbodyを分割する(:で判断)
  # bodyをスペースごとに分割する
  # 分割したbodyのリストを逆順に並べ替える
  # bodyを結合する
  # headerからbodyの分割のフォーマットを選択する
  # フォーマットに従って分割する
  # 整形したbodyをreturnする
  private
  @@bodyformat = Struct.new(:name,   :size_in_byte)

  module EventId
    NO1000  = "1000".freeze
    NO1001  = "1001".freeze
    OTHER   = "".freeze
  end

  BODY_FORMAT = {
    EventId::NO1000 =>[
      @@bodyformat.new("body1", 4),
      @@bodyformat.new("body2", 2),
      @@bodyformat.new("body3", 2),
      @@bodyformat.new("body4", 4),
      @@bodyformat.new("body5", 4),
    ],
    EventId::NO1001 =>[
      @@bodyformat.new("body1", 16)
    ],
    EventId::OTHER  =>[],
  }

  def select_body_format(header)
    BODY_FORMAT.each do |key, value|
      if header.include?(key)
        return value
      end
    end
    return BODY_FORMAT[EventId::OTHER]
  end
  
  def parse_body(format_list:, str:)
    return "" if format_list.empty?
    
    format = format_list.first

    if str.length < format.size_in_byte
      return "error"
    else
      rest_format = format_list[1..-1]
      data = str.slice(-format.size_in_byte..)
      rest_data = str.slice(..(str.length - format.size_in_byte - 1))

      return "#{format.name}: #{data}  #{parse_body(format_list: rest_format, str:rest_data)}"
    end
  end 

  public
  def calculate_status(dumpstr)
    dumpinfo    = dumpstr.split(":")
    header      = dumpinfo.first
    body        = dumpinfo.last

    format_list = select_body_format(header)
    body_str    = body.split(" ").reverse.join

    return parse_body(format_list: format_list, str:body_str)
  end
end

if __FILE__ == $0
  puts "入力待ち…"
  input = gets.chomp

  sfd = StatusFromDumpstr.new
  puts sfd.calculate_status(input)
end