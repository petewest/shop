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

  test "should allow duplicate symbols" do
    currency=Currency.new(valid)
    currency.symbol=currencies(:gbp).symbol
    assert currency.save
  end

  test "should have an iso code of exactly 3 characters long" do
    assert %w(tw four TW FOUR).none?{|c| Currency.new(valid.merge(iso_code: c)).valid? }
  end

  test "should not allow invalid iso codes" do
    invalid_codes=%w(123 g.p g_p g21 12g `12 /34)
    assert invalid_codes.none?{|code| Currency.new(valid.merge(iso_code: code)).valid?}
  end

  test "should nullify product currencies on destroy" do
    product=products(:tshirt)
    currency=product.currency
    currency.destroy
    product.reload
    assert_nil product.currency_id
  end

  test "should nullify line_item currencies on destroy" do
    line_item=line_items(:one)
    currency=line_item.currency
    currency.destroy
    line_item.reload
    assert_nil line_item.currency_id
  end

  private
    def valid
      @currency||={iso_code: "AUD", symbol: "AU$", decimal_places: 2}
    end
end
