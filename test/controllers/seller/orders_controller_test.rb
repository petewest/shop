require 'test_helper'

class Seller::OrdersControllerTest < ActionController::TestCase
  test "should not get index as anon" do
    get :index
    assert_redirected_to signin_path
  end

  test "should not get index as buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should get index as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_select ".order_item", [30, Order.count].min
  end

  test "should be able to progress order from paid to dispatched" do
    sign_in users(:seller)
    order=orders(:paid)
    patch :update, id: order.id, order: {status: "dispatched"}
    order.reload
    assert order.dispatched?, "Debug: #{order.errors.inspect}"
  end

  test "should get detail page for order" do
    sign_in users(:seller)
    order=orders(:placed)
    get :show, id: order.id
    assert_response :success
    assert_not_nil assigns(:order)
  end

  test "should send dispatch notification" do
    sign_in users(:seller)
    order=orders(:paid)
    ActionMailer::Base.deliveries.clear
    patch :update, id: order.id, order: {status: "dispatched"}
    assert_not ActionMailer::Base.deliveries.empty?
    email=ActionMailer::Base.deliveries.first
    assert_equal [order.user.email], email.to
  end

  test "should get only users orders when asked" do
    sign_in users(:seller)
    user=users(:buyer)
    get :index, user_id: user.id
    assert_response :success
    assert_equal user.orders.size, assigns(:orders).size
  end

  test "should get only orders where gift_card has been redeemed when asked" do
    sign_in users(:seller)
    gift_card=gift_cards(:spent_on_order)
    get :index, gift_card_id: gift_card.id
    assert_response :success
    assert_not_nil assigns(:orders)
    assert assigns(:orders).include?(orders(:bought_with_gift_card))
    assert_not assigns(:orders).include?(orders(:paid))
  end
end
