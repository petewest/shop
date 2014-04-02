require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  test "should respond to iso_code" do
    currency=Currency.new
    assert_respond_to currency, :iso_code
  end

  test "should save when valid" do
    currency=Currency.new(valid)
    assert currency.save
  end

  test "should not save without iso code" do
    currency=Currency.new(valid.except(:iso_code))
    assert_not currency.save
  end

  test "should not save without symbol" do
    currency=Currency.new(valid.except(:symbol))
    assert_not currency.save
  end

  test "should not save without decimal_places" do
    currency=Currency.new(valid.except(:decimal_places))
    assert_not currency.save
  end

  test "should not allow duplicate iso codes" do
    currency=Currency.new(valid)
    currency.iso_code=currencies(:gbp).iso_code
    assert_not currency.save
  end

  private
    def valid
      @currency||={iso_code: "AUD", symbol: "AU$", decimal_places: 2}
    end
end
