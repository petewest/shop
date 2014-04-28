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

  test "should create cancellation email for buyer" do
    buyer=users(:buyer)
    order=buyer.orders.first
    email=OrderMailer.cancel_email(order).deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], email.to
    assert_equal ["test@example.com"], email.from
    assert_equal "Order ##{order.id} cancelled", email.subject
  end

  test "should inform the seller the order has been cancelled" do
    buyer=users(:buyer)
    order=buyer.orders.first
    email=OrderMailer.cancel_email_seller(order).deliver
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal Seller.pluck(:email), email.to
    assert_not email.to.include?(buyer.email)
    assert_equal ["test@example.com"], email.from
    assert_equal "Order ##{order.id} cancelled", email.subject
  end
end
