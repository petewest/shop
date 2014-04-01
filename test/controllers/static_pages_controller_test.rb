require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "h1", "Welcome to the shop"
    assert_select "title", "Shop!"
    assert_select "nav"
    assert_select "a[href=#{root_url}]", "Shop!"
    assert_select "a[href=#{signin_path}]", "Sign in"
    assert_select "a[href=#{signup_path}]", "Sign up"
  end

  test "should show seller menu when logged in as seller" do
    sign_in users(:seller)
    get :home
    assert_select "a", "Seller"
    assert_select "a[href=#{new_product_path}]"
  end

end
