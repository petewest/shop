require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get login page" do
    get :new
    assert_response :success
    assert_select "form"
  end

  test "should set cookie if permanent" do
    sign_in users(:buyer), true
    assert_not_nil cookies[:remember_token]
  end

  test "should set session if not permanent" do
    sign_in users(:buyer)
    assert_not_nil session[:remember_token]
  end

  test "sign out should clear remember token" do
    sign_in users(:buyer), true
    assert_difference "Session.count", -1 do
      delete :destroy
    end
    assert_nil cookies[:remember_token]
  end

  test "sign out should clear session token" do
    sign_in users(:buyer)
    assert_difference "Session.count", -1 do
      delete :destroy
    end
    assert_nil session[:remember_token]
  end

  test "should clear cart token on signout if cart belongs to a user" do
    sign_in users(:buyer)
    buyer_cart=users(:buyer).carts.first
    cookies[:cart_token]=buyer_cart.cart_token
    assert_not_nil cookies[:cart_token]
    delete :destroy
    #sign_in sets @current_user for this object
    #but the :destroy action removes @current_user for ITS object, not this one
    #that's fine with atomic requests, but breaks the testing unless we clear it here
    #but this isn't a cheat :)
    #calling current_cart will re-evaluate who the current user is and re-set it
    #if the user is still logged in
    @current_user=nil
    assert_nil cookies[:cart_token]
    assert_not_equal buyer_cart, current_cart, "Debug: user: #{current_user.inspect}"
  end

end
