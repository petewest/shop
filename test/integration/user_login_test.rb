require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should create new permanent session" do
    user=User.new(valid_user)
    user.save
    assert_difference "Session.count" do
      post sessions_path, session: valid_session_params.merge(remember: 1)
    end
    assert_response :redirect
    assert_redirected_to root_url
    assert_equal "Welcome back, #{valid_user[:name]}", flash[:success]
    #assert_not_nil cookies[:remember_token]
    assert_not_nil assigns(:current_user)
    assert_equal assigns(:current_user), user
  end

  test "should create new temporary session" do
    user=User.new(valid_user)
    user.save
    assert_difference "Session.count" do
      post sessions_path, session: valid_session_params
    end
    assert_response :redirect
    assert_redirected_to root_url
    assert_equal "Welcome back, #{valid_user[:name]}", flash[:success]
    assert_not_nil session[:remember_token]
    assert_not_nil assigns(:current_user)
    assert_equal assigns(:current_user), user
  end

  test "should not log in with incorrect details" do
    user=User.new(valid_user)
    user.save
    assert_no_difference "Session.count" do
      post sessions_path, session: valid_session_params.merge(password: "wrong password")
    end
    assert_equal "Incorrect login", flash[:danger]
    assert_nil assigns(:current_user)
    assert_template :new
    assert_select "form"
    get root_url
    assert_not_equal "Incorrect login", flash[:danger]
  end


  private
    def valid_user
      @valid_user||={email: "test@test.com", password: "foobar", password_confirmation: "foobar", name: "Test user"}
    end
    def valid_session_params
      @valid_session=valid_user.except(:password_confirmation, :name)
    end
end
