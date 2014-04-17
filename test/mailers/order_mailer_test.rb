require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  test "should create order confirmation" do
    buyer=users(:buyer)
    seller=users(:seller)
    order=buyer.orders.first
    email=OrderMailer.confirmation_email(buyer, order).deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], email.to
    assert_equal [seller.email], email.from
    assert email.bcc.include? seller.email
    assert_not email.bcc.include? users(:seller2).email
    assert_not email.bcc.include? users(:buyer_with_bcc).email
  end
end
