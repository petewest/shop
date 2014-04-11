require 'test_helper'

class AddressesControllerTest < ActionController::TestCase
  test "should not be accessible when not logged in" do
    get :index
    assert_redirected_to signin_path
  end

  test "should get index when logged in as buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
    assert_select ".address_container"
    assert_select "a", "Edit"
  end

  test "should get current users addresses" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
    assert assigns(:addresses).include?(addresses(:home)), "Debug: User: #{current_user.inspect} addresses: #{assigns(:addresses).inspect}"
  end

  test "should not get other user addresses" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
    assert_not assigns(:addresses).include?(addresses(:seller_home))
  end

  test "should get new page (html)" do
    sign_in users(:buyer)
    get :new
    assert_response :success
    assert_not_nil assigns(:address)
    assert_equal current_user, assigns(:address).user
    assert_select "form"
  end

  test "should get new page (js)" do
    sign_in users(:buyer)
    xhr :get, :new
    assert_response :success
    assert_not_nil assigns(:address)
    assert_equal current_user, assigns(:address).user
  end

  test "should add address" do
    sign_in users(:buyer)
    assert_difference "Address.count" do
      post :create, address: valid
    end
    assert_not_nil assigns(:address)
    assert_equal current_user, assigns(:address).user
    assert_redirected_to addresses_url
  end

  test "should show new screen when create invalid" do
    sign_in users(:buyer)
    assert_no_difference "Address.count" do
      post :create, address: valid.except(:label)
    end
    assert_response :success
    assert_template 'new'
  end

  test "should have an edit screen" do
    sign_in users(:buyer)
    address=users(:buyer).addresses.first
    get :edit, id: address.id
    assert_response :success
  end

  test "should update record" do
    sign_in users(:buyer)
    address=users(:buyer).addresses.first
    assert_not_equal valid[:label], address.label
    assert_not_equal valid[:address], address.address
    patch :update, id: address.id, address: valid
    assert_redirected_to addresses_url
    address.reload
    assert_equal valid[:label], address.label
    assert_equal valid[:address], address.address
  end

  test "should remove address" do
    sign_in users(:buyer)
    address=users(:buyer).addresses.first
    assert_difference "Address.count", -1 do
      delete :destroy, id: address.id
    end
    assert_response :redirect
    assert_redirected_to addresses_url
  end

  test "should not remove address" do
    sign_in users(:buyer)
    address=users(:seller).addresses.first
    assert_no_difference "Address.count" do
      assert_raises ActiveRecord::RecordNotFound do
        delete :destroy, id: address.id
      end
    end
  end


  private
    def valid
      @add||={label: "New address", address: "Somewhere avenue", default_billing: 'f', default_delivery: 'f'}
    end
end
