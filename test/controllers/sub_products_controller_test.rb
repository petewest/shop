require 'test_helper'

class SubProductsControllerTest < ActionController::TestCase
  def setup
    @product=products(:tshirt)
  end

  test "should get new page" do
    sign_in users(:seller)
    get :new, product_id: @product.id
    assert_response :success
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

  test "should create item when valid" do
    sign_in users(:seller)
    assert_difference "SubProduct.count" do
      post :create, product_id: @product.id, sub_product: valid
    end
    assert_redirected_to [@product, :sub_products]
  end

  private
    def valid
      @sub_product||={name: "Medium", currency_id: currencies(:gbp).id, unit_cost: 200}
    end
end
