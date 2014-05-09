require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  # Allow use of url helpers in this test
  include Rails.application.routes.url_helpers

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end

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

  test "should have gift card codes for any gift cards in order" do
    order=orders(:gift_card_paid)
    gift_card=gift_cards(:gift_card_paid)
    email=OrderMailer.confirmation_email(order).deliver
    assert_match redeem_gift_cards_url(id: gift_card.encoded_token), email.html_part.decoded
    assert_match redeem_gift_cards_url(id: gift_card.encoded_token), email.text_part.decoded
  end
end
