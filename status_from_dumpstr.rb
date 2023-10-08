# ダンプデータの整形ツール

require 'test/unit'

class StatusFromDumpstr
    # TODO:
    # headerとtextを分割する(:で判断)
    # textをスペースごとに分割する
    # 分割したtextのリストを逆順に並べ替える
    # textを結合する
    # headerからtextの分割のフォーマットを選択する
    # フォーマットに従って分割する
    # 整形したtextをreturnする
    private
    
    @@dumpformat = Struct.new(:header, :text)
    @@textformat = Struct.new(:name,   :size_in_byte)

    module EventId
        NO1000  = 0.freeze
        NO1001  = 1.freeze
        OTHER   = 3.freeze
    end

    TEXT_FORMAT = {
        EventId::NO1000 =>[
            @@textformat.new("text1", 4),
            @@textformat.new("text2", 2),
            @@textformat.new("text3", 2),
            @@textformat.new("text4", 4),
            @@textformat.new("text5", 4),
        ],
        EventId::NO1001 =>[
            @@textformat.new("text1", 16)
        ],
        EventId::OTHER  =>[],
    }

    def split_header_and_text(dumpstr)
        if dumpstr.respond_to?("split")
            header_and_text = dumpstr.split(":")
            if header_and_text.size == 2
                return @@dumpformat.new(header_and_text[0], header_and_text[1])
            end
        end
        return @@dumpformat.new("", "")
    end

    def split_text_by_space(text)
        if text.respond_to?("split")
            text_list = text.split(" ")
            return text_list
        end
        return []
    end

    def reverse_list(list)
        if list.respond_to?("reverse")
            return list.reverse
        end
        return []
    end

    def strlist_to_str(list)
        if list.respond_to?("join")
            return list.join
        end
        return ""
    end

    def select_text_format(header)
        case header
            in "header 1000"
                return TEXT_FORMAT[EventId::NO1000]
            in "header 1001"
                return TEXT_FORMAT[EventId::NO1001]
            in _
                return TEXT_FORMAT[EventId::OTHER]
        end
        #dummy
        return TEXT_FORMAT[EventId::OTHER]
    end

    def parse_text(format:, str:)
        if format.length == 0
            return ""
        elsif str.length < format.first.size_in_byte
            return "error"
        end
        
        return "#{format.first.name}: #{str.slice(-format.first.size_in_byte..)}  #{parse_text(format: format.last(format.length - 1), str:str.slice(..(str.length - format.first.size_in_byte - 1)))}"
    end

    public
    def calculate_status(dumpstr)
        dumpinfo    = split_header_and_text(dumpstr)
        text_str    = strlist_to_str(reverse_list(split_text_by_space(dumpinfo.text)))
        
        # for test
        # puts text_str

        text_format  = select_text_format(dumpinfo.header)
        return parse_text(format: text_format, str:text_str)
    end
end

class TestForStatusFromDumpstr < Test::Unit::TestCase
    def test_sfd
        sfd = StatusFromDumpstr.new
        assert_equal sfd.calculate_status("header 1000:3210 7654 ba98 fedc"), "text1: 3210  text2: 54  text3: 76  text4: ba98  text5: fedc  "
        assert_equal sfd.calculate_status("header 1001:3210 7654 ba98 fedc"), "text1: fedcba9876543210  "
        assert_equal sfd.calculate_status("header hoge:3210 7654 ba98 fedc"), ""
    end
end

if __FILE__ == $0
    # hoge
end