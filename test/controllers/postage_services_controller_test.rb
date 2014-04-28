require 'test_helper'

class PostageServicesControllerTest < ActionController::TestCase
  test "should not get index as buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should not get index as anonymouse" do
    get :index
    assert_redirected_to signin_path
  end

  test "should get index as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:postage_services)
  end

  test "should get new as seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert_not_nil assigns(:postage_service)
    assert_select "h1", "New postage service"
  end

  test "should create new item (html)" do
    sign_in users(:seller)
    assert_difference "PostageService.count" do
      post :create, postage_service: valid
    end
    assert_redirected_to postage_services_path
  end

  test "should create new item (js)" do
    sign_in users(:seller)
    assert_difference "PostageService.count" do
      xhr :post, :create, postage_service: valid
    end
    assert_template 'create'
  end


  private
    def valid
      {name: "New postage service", default: 'f'}
    end
end
