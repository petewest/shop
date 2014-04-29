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

  test "should get edit" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    get :edit, id: postage_service.id
    assert_response :success
  end

  test "should update item (html)" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    patch :update, id: postage_service.id, postage_service: valid
    postage_service.reload
    assert_equal valid[:name], postage_service.name
    assert_not postage_service.default?
  end

  test "should update item (js)" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    xhr :patch, :update, id: postage_service.id, postage_service: valid
    assert_template 'update'
    postage_service.reload
    assert_equal valid[:name], postage_service.name
    assert_not postage_service.default?
  end

  test "should not update item (js)" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    xhr :patch, :update, id: postage_service.id, postage_service: valid.merge(name: "")
    assert_equal "Update failed", flash[:danger]
    assert_template 'edit'
  end


  test "should destroy item (html)" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    assert_difference "PostageService.count", -1 do
      delete :destroy, id: postage_service.id
    end
    assert_equal "Postage service removed", flash[:success]
    assert_redirected_to postage_services_path
  end

  test "should destroy item (js)" do
    sign_in users(:seller)
    postage_service=postage_services(:first_class)
    assert_difference "PostageService.count", -1 do
      xhr :delete, :destroy, id: postage_service.id
    end
    assert_template 'destroy'
  end


  private
    def valid
      {name: "New postage service", default: 'f'}
    end
end
