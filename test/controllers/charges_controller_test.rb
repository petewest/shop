require 'test_helper'

class ChargesControllerTest < ActionController::TestCase
  test "should not get index for buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should not get index for anonymous" do
    get :index
    assert_redirected_to signin_path
  end

  test "should get index for seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:charges)
  end

  test "should not get refund action for buyer" do
    sign_in users(:buyer)
    post :refund, id: "ch_made_up"
    assert_redirected_to signin_path
  end
  test "should not get refund action for anonymous" do
    post :refund, id: "ch_made_up"
    assert_redirected_to signin_path
  end

  test "should not get show page for buyer" do
    sign_in users(:buyer)
    order=orders(:paid)
    get :show, id: order.stripe_charge_reference
    assert_redirected_to signin_path
  end

  test "should not get show page for anonymous" do
    order=orders(:paid)
    get :show, id: order.stripe_charge_reference
    assert_redirected_to signin_path
  end

  test "should redirect to charges page for seller with incorrect id" do
    #we don't have a valid id to test here, so just check it allows through the before_filter
    sign_in users(:seller)
    order=orders(:paid)
    get :show, id: order.stripe_charge_reference
    assert_redirected_to charges_url
  end
end
