require 'test_helper'

class GiftCardTest < ActiveSupport::TestCase
  def setup
    @gift_card_new=GiftCard.new(valid)
  end

  test "should create if valid" do
    assert @gift_card_new.save
  end

  test "should not be valid? without buyer" do
    @gift_card_new.buyer=nil
    assert_not @gift_card_new.valid?
  end

  test "should not be valid? without start_value" do
    @gift_card_new.start_value=nil
    assert_not @gift_card_new.valid?
  end

  test "should not save where start_value is zero" do
    @gift_card_new.start_value=0
    assert_not @gift_card_new.valid?
  end

  test "should not save where start_value is negative" do
    @gift_card_new.start_value=-1
    assert_not @gift_card_new.valid?
  end

  test "should set token on intialise if none exists" do
    assert_not_nil @gift_card_new.token
  end

  test "should not save without token" do
    @gift_card_new.token=nil
    assert_not @gift_card_new.valid?
  end

  test "should copy start_value to current_value on first save" do
    @gift_card_new.save
    @gift_card_new.reload
    assert_equal valid[:start_value], @gift_card_new.current_value
  end

  test "should not allow a negative current_value" do
    @gift_card_new.current_value=-1
    assert_not @gift_card_new.valid?
  end

  test "should allow a zero current_value" do
    @gift_card_new.current_value=0
    assert @gift_card_new.valid?
  end

  test "should allow current_value to be equal to start_value" do
    @gift_card_new.current_value=@gift_card_new.start_value
    assert @gift_card_new.valid?
  end

  test "shouldn't allow a current_value bigger than start_value" do
    @gift_card_new.current_value=@gift_card_new.start_value+1
    assert_not @gift_card_new.valid?
  end

  test "should not allow current_value to be nil once saved" do
    @gift_card_new.save
    @gift_card_new.current_value=nil
    assert_not @gift_card_new.valid?
  end

  test "should have an encoded_token method" do
    assert_respond_to @gift_card_new, :encoded_token
  end

  test "should have a class method to find by encoded_token" do
    assert_respond_to GiftCard, :find_by_encoded_token
  end

  test "should raise an error when given an incorrect token" do
    @gift_card_new.save
    assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
      GiftCard.find_by_encoded_token(@gift_card_new.token)
    end
  end

  test "should not save without currency" do
    @gift_card_new.currency=nil
    assert_not @gift_card_new.valid?
  end

  test "should have 'in_credit' scope" do
    assert_respond_to GiftCard, :in_credit
  end

  test "should only return items with balance remaining" do
    cards=GiftCard.in_credit
    assert cards.include?(gift_cards(:ten_pounds))
    assert_not cards.include?(gift_cards(:used))
  end

  test "should not allow non-integer start_value" do
    @gift_card_new.start_value=100.5
    assert_not @gift_card_new.valid?
  end

  test "should not allow non-integer current_value" do
    @gift_card_new.current_value=100.5
    assert_not @gift_card_new.valid?
  end

  test "should have decimal_value virtual methods for setting start_value field" do
    @gift_card_new.decimal_value=20.50
    assert_equal 2050, @gift_card_new.start_value
    assert @gift_card_new.valid?, "Errors: #{@gift_card_new.errors.inspect}"
  end

  test "should have decimal_value virtual methods for reading start_value field" do
    assert_equal 20.00, @gift_card_new.decimal_value
  end

  test "should floor value if setting too many decimals" do
    @gift_card_new.decimal_value=20.509
    assert_equal 2050, @gift_card_new.start_value
    assert @gift_card_new.valid?
  end

  private
    def valid
      {buyer: users(:buyer), start_value: 2000, currency: currencies(:gbp)}
    end
end
