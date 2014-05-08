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
    assert_not @gift_card_new.save
  end

  test "should not allow current_value to be nil once saved" do
    @gift_card_new.save
    @gift_card_new.current_value=nil
    assert_not @gift_card_new.valid?
  end

  test "should have an encoded_token method" do
    assert_respond_to @gift_card_new, :encoded_token
  end

  test "should have a class method to find by encoded_token and raise" do
    assert_respond_to GiftCard, :find_by_encoded_token!
  end


  test "should raise an error when given an incorrect token" do
    @gift_card_new.save
    assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
      GiftCard.find_by_encoded_token!(@gift_card_new.token)
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

  test "should have unit_cost virtual methods for setting start_value field" do
    @gift_card_new.unit_cost=2050
    assert_equal 2050, @gift_card_new.start_value
    assert @gift_card_new.valid?, "Errors: #{@gift_card_new.errors.inspect}"
  end

  test "should have unit_cost virtual methods for reading start_value field" do
    assert_equal 2000, @gift_card_new.unit_cost
  end

  test "should decrement current_value when start_value is reduced (starting same)" do
    @gift_card_new.save
    current=@gift_card_new.current_value
    @gift_card_new.start_value-=50
    assert @gift_card_new.valid?, @gift_card_new.errors.inspect
    assert @gift_card_new.save
    @gift_card_new.reload
    assert_equal current-50, @gift_card_new.current_value
  end

  test "should decrement current_value when start_value is reduced after some has been redeemed" do
    @gift_card_new.save
    @gift_card_new.current_value-=200
    @gift_card_new.save
    current=@gift_card_new.current_value
    @gift_card_new.start_value-=50
    assert @gift_card_new.valid?, @gift_card_new.errors.inspect
    assert @gift_card_new.save
    assert_equal current-50, @gift_card_new.reload.current_value
  end

  test "should not allow a start_value reduction to take current_value below zero" do
    @gift_card_new.save
    @gift_card_new.current_value-=200
    @gift_card_new.save
    current=@gift_card_new.current_value
    @gift_card_new.start_value-=(current+10) 
    assert_not @gift_card_new.save
  end

  test "should increment current_value by start_value increment" do
    @gift_card_new.save
    current_value=@gift_card_new.current_value
    @gift_card_new.start_value+=50
    @gift_card_new.save
    assert_equal current_value+50, @gift_card_new.reload.current_value
  end

  test "should have a redeemable scope" do
    assert_respond_to GiftCard, :redeemable
  end

  test "should only return items without a redeemer" do
    redeemable=GiftCard.redeemable
    [:no_user, :bought_by_buyer].each do |item|
      assert redeemable.include?(gift_cards(item)), "#{item} not present"
    end
    [:ten_pounds, :other_user, :used].each do |item|
      assert_not redeemable.include?(gift_cards(item)), "#{item} present"
    end
  end


  private
    def valid
      {buyer: users(:buyer), start_value: 2000, currency: currencies(:gbp)}
    end
end
