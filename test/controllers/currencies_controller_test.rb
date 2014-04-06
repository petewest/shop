require 'test_helper'

class CurrenciesControllerTest < ActionController::TestCase
  test "should not get index without sign in" do
    get :index
    assert_response :redirect
  end

  test "should not get index with sign in as buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :redirect
  end

  test "should get index when signed in as seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:currencies)
  end

  test "should allow edit (html)" do
    sign_in users(:seller)
    currency=currencies(:gbp)
    get :edit, id: currency.id
    assert_response :success
  end

  test "should allow edit (js)" do
    sign_in users(:seller)
    currency=currencies(:gbp)
    xhr :get, :edit, id: currency.id
    assert_response :success
  end

  test "should allow update with valid details (html)" do
    sign_in users(:seller)
    currency=currencies(:gbp)
    patch :update, id: currency.id, currency: valid
    assert_not_nil assigns(:currency)
    currency.reload
    assert_equal valid[:iso_code], currency.iso_code
    assert_equal valid[:symbol], currency.symbol
    assert_equal valid[:decimal_places], currency.decimal_places
    assert_redirected_to currencies_url
  end

  test "should allow update with valid details (js)" do
    sign_in users(:seller)
    currency=currencies(:gbp)
    xhr :patch, :update, id: currency.id, currency: valid
    assert_not_nil assigns(:currency)
    currency.reload
    assert_equal valid[:iso_code], currency.iso_code
    assert_equal valid[:symbol], currency.symbol
    assert_equal valid[:decimal_places], currency.decimal_places
    assert_template 'update'
  end

  test "should allow new (html)" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert assigns(:currency)
    assert assigns(:currency).new_record?
  end

  test "should allow new (js)" do
    sign_in users(:seller)
    xhr :get, :new
    assert_response :success
    assert assigns(:currency)
    assert assigns(:currency).new_record?
  end





  private
    def valid
      {iso_code: "AUD", symbol: "AU$", decimal_places: 2}
    end
end
