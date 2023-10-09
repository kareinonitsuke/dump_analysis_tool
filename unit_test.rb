require 'test/unit'
require './status_from_dumpstr'

class TestForStatusFromDumpstr < Test::Unit::TestCase
  def test_sfd
    sfd = StatusFromDumpstr.new
    assert_equal sfd.calculate_status("header 1000:3210 7654 ba98 fedc"), "body1: 3210  body2: 54  body3: 76  body4: ba98  body5: fedc  "
    assert_equal sfd.calculate_status("header 1001:3210 7654 ba98 fedc"), "body1: fedcba9876543210  "
    assert_equal sfd.calculate_status("header hoge:3210 7654 ba98 fedc"), ""
  end
end