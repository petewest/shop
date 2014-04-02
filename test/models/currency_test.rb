require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  test "should respond to iso_code" do
    currency=Currency.new
    assert_respond_to currency, :iso_code
  end
end
