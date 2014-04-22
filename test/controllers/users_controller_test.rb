require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
    assert_select "h1", "Sign up"
    assert_select "title", "Shop! | Sign up"
    assert assigns(:user)
    assert_select "form input"
  end

  test "should create user" do
    assert_difference "User.count" do
      put :create, user: valid
    end
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal "Welcome #{assigns(:user).name}", flash[:success]
  end

  test "should show error when not creating user" do
    assert_no_difference "User.count" do
      post :create, user: valid.except(:password)
    end
    assert_equal "New user creation failed", flash[:danger]
    get :new
    assert_not_equal "New user creation failed", flash[:danger]
  end

  test "should not get edit page" do
    get :edit
    assert_redirected_to signin_path
  end

  test "should get edit page" do
    sign_in users(:buyer)
    get :edit
    assert_response :success
    assert_select "h1", "My account"
    assert_not_nil assigns(:user)
    assert_equal users(:buyer), assigns(:user)
    assert_select "form"
    assert_select "input[type=password]", 0
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[email]']"
  end

  private
    def valid
      {name: "Test name", email: "test@email.com", password: "foobar", password_confirmation: "foobar"}
    end
end
