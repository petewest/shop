require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  test "should create order confirmation" do
    buyer=users(:buyer)
    seller=users(:seller)
    order=buyer.orders.first
    email=OrderMailer.confirmation_email(order).deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], email.to
    assert_equal ["test@example.com"], email.from
    assert email.bcc.include?(seller.email)
    assert_not email.bcc.include?(users(:seller2).email)
    assert_not email.bcc.include?(users(:buyer_with_bcc).email)
  end

  test "should create dispatch notification" do
    buyer=users(:buyer)
    order=buyer.orders.first
    email=OrderMailer.dispatch_email(order).deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], email.to
    assert_equal ["test@example.com"], email.from
    assert_equal "Order ##{order.id} dispatched", email.subject
  end
end
