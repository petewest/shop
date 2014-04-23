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
    assert_select "input[name='user[bcc_on_email]']", 0
  end
  test "should show different form for seller" do
    sign_in users(:seller)
    get :edit
    assert_select "input[name='seller[name]']"
    assert_select "input[name='seller[email]']"
    assert_select "input[name='seller[bcc_on_email]']"
  end

  test "should change name" do
    user=users(:buyer)
    sign_in user
    patch :update, user: {name: "New name"}
    user.reload
    assert_equal "New name", user.name, "Debug: #{assigns(:user).errors.inspect}"
    assert_redirected_to root_url
  end

  test "should not allow update without signin" do
    patch :update, user: {name: "New name"}
    assert_redirected_to signin_path
  end

  test "should not allow seller params for buyer" do
    sign_in users(:buyer)
    assert_raises ActionController::ParameterMissing do
      patch :update, seller: {name: "New name"}
    end
  end
  test "should not allow buyer params for seller" do
    sign_in users(:seller)
    assert_raises ActionController::ParameterMissing do
      patch :update, user: {name: "New name"}
    end
  end

  test "should update bcc flag for seller" do
    user=users(:seller2)
    sign_in user
    assert_not user.bcc_on_email
    patch :update, seller: {bcc_on_email: 't'}
    user.reload
    assert user.bcc_on_email
  end

  test "should not update bcc flag for buyer" do
    user=users(:buyer)
    sign_in user
    assert_not user.bcc_on_email
    patch :update, user: {bcc_on_email: 't'}
    user.reload
    assert_not user.bcc_on_email
  end

  test "should get password screen" do
    user=users(:buyer)
    sign_in user
    get :password
    assert_response :success
    assert_not_nil assigns(:user)
    assert_select "form[action=#{update_password_user_path}]"
  end

  test "should not get password screen" do
    get :password
    assert_redirected_to signin_path
  end

  test "should change password" do
    user=User.create(valid)
    sign_in user
    patch :update_password, user: { old_password: valid[:password], password: "new password", password_confirmation: "new password" }
    user.reload
    assert_not user.authenticate(valid[:password])
    assert_equal user, user.authenticate("new password")
  end

  test "should change password for seller" do
    user=User.create(valid.merge(type: "Seller"))
    sign_in user
    patch :update_password, seller: { old_password: valid[:password], password: "new password", password_confirmation: "new password" }
    user.reload
    assert_not user.authenticate(valid[:password])
    assert_equal user, user.authenticate("new password")
  end

  test "should not change password if old password doesn't match" do
    user=User.create(valid)
    sign_in user
    patch :update_password, user: { old_password: "something else", password: "new password", password_confirmation: "new password" }
    user.reload
    assert_select ".field_with_errors>input[name='user[old_password]']"
    assert_not user.authenticate("new password")
    assert_equal user, user.authenticate(valid[:password])
  end

  test "should not give success with blank password" do
    user=User.create(valid)
    sign_in user
    patch :update_password, user: { old_password: valid[:password], password: "", password_confirmation: "" }
    user.reload
    assert_equal "Password change failed", flash[:danger]
    assert_nil flash[:success]
    assert_template 'password'
  end
  private
    def valid
      {name: "Test name", email: "test@email.com", password: "foobar", password_confirmation: "foobar"}
    end
end
