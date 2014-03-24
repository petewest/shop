require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "h1", "Welcome to the shop"
    assert_select "title", "Shop!"
    assert_select "nav"
    assert_select "a[href=#{root_url}]", "Shop!"
    assert_select 'a[href=#]', "Sign in"
    assert_select "a[href=#{new_user_path}]", "Sign up"
  end

end
