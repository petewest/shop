require 'test_helper'

class SubProductsControllerTest < ActionController::TestCase
  def setup
    @product=products(:tshirt)
  end

  test "should get new page" do
    sign_in users(:seller)
    get :new, product_id: @product.id
    assert_response :success
    assert_equal @product, assigns(:product)
    assert_not_nil assigns(:sub_product)
  end

  test "should not get new page" do
    get :new, product_id: @product.id
    assert_redirected_to  signin_path
  end

  test "should not get new page for buyer" do
    sign_in users(:buyer)
    get :new, product_id: @product.id
    assert_redirected_to  signin_path
  end

  test "should get an index" do
    sign_in users(:seller)
    get :index, product_id: @product.id
    assert_response :success
  end

  test "should copy attributes (except name) from product to sub product" do
    sign_in users(:seller)
    get :new, product_id: @product.id
    assert_not_equal @product.name, assigns(:sub_product).name
    @product.attributes.symbolize_keys.except(:id, :updated_at, :created_at, :type, :name, :master_product_id).each do |key, value|
      assert_equal value, assigns(:sub_product)[key], "#{key} mismatch"
    end
  end

end
