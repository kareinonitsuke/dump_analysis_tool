# ダンプデータの整形ツール

require 'test/unit'

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
    
    @@dumpformat = Struct.new(:header, :body)
    @@bodyformat = Struct.new(:name,   :size_in_byte)

    module EventId
        NO1000  = "1000".freeze
        NO1001  = "1001".freeze
        OTHER   = "this is dummy text".freeze
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

    def split_header_and_body(dumpstr)
        if dumpstr.respond_to?("split")
            header_and_body = dumpstr.split(":")
            if header_and_body.size == 2
                return @@dumpformat.new(header_and_body[0], header_and_body[1])
            end
        end
        return @@dumpformat.new("", "")
    end

    def select_body_format(header)
        BODY_FORMAT.each do |key, value|
            if header.include?(key)
                return value
            end
        end
        return BODY_FORMAT[EventId::OTHER]
    end

    def parse_body(format:, str:)
        if format.length == 0
            return ""
        elsif str.length < format.first.size_in_byte
            return "error"
        else
            return "#{format.first.name}: #{str.slice(-format.first.size_in_byte..)}  #{parse_body(format: format.last(format.length - 1), str:str.slice(..(str.length - format.first.size_in_byte - 1)))}"
        end
    end

    public
    def calculate_status(dumpstr)
        dumpinfo    = split_header_and_body(dumpstr)
        body_str    = dumpinfo.body.split(" ").reverse.join

        body_format  = select_body_format(dumpinfo.header)
        return parse_body(format: body_format, str:body_str)
    end
end

class TestForStatusFromDumpstr < Test::Unit::TestCase
    def test_sfd
        sfd = StatusFromDumpstr.new
        assert_equal sfd.calculate_status("header 1000:3210 7654 ba98 fedc"), "body1: 3210  body2: 54  body3: 76  body4: ba98  body5: fedc  "
        assert_equal sfd.calculate_status("header 1001:3210 7654 ba98 fedc"), "body1: fedcba9876543210  "
        assert_equal sfd.calculate_status("header hoge:3210 7654 ba98 fedc"), ""
    end
end

if __FILE__ == $0
    puts "入力待ち…"
    input = gets

    sfd = StatusFromDumpstr.new
    puts sfd.calculate_status(input)
end