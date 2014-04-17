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
    assert_select "tr", Order.count+1
  end

  test "should be able to progress order from placed to dispatched" do
    sign_in users(:seller)
    order=orders(:placed)
    patch :update, id: order.id, order: {status: "dispatched"}
    order.reload
    assert order.dispatched?
  end

  test "should get detail page for order" do
    sign_in users(:seller)
    order=orders(:placed)
    get :show, id: order.id
    assert_response :success
    assert_not_nil assigns(:order)
  end
end
