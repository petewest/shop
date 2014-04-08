require 'test_helper'

class StockLevelsControllerTest < ActionController::TestCase
  def setup
    @product=products(:tshirt)
  end
  
  test "should not be accessible from anonymous" do
    get :index, product_id: @product.id
    assert_response :redirect
  end

  test "should not be accessible from non-seller account" do
    sign_in users(:buyer)
    get :index, product_id: @product.id
    assert_response :redirect
  end

  test "should be accessible from seller account" do
    sign_in users(:seller)
    get :index, product_id: @product.id
    assert_response :success
  end

  test "should get new" do
    sign_in users(:seller)
    get :new, product_id: @product.id
    assert_response :success
    assert_not_nil assigns(:stock_level)
    assert_select "form"
  end

  test "should not get new as buyer" do
    sign_in users(:buyer)
    get :new, product_id: @product.id
    assert_response :redirect
  end

  test "should create new stock when valid" do
    sign_in users(:seller)
    assert_difference "StockLevel.count" do
      assert_difference "@product.stock_levels.count" do
        post :create, product_id: @product.id, stock_level: valid
      end
    end
    assert_redirected_to product_stock_levels_url(@product)
  end



  private
    def valid
      @stock_level||={due_at: 5.days.ago, start_quantity: 20}
    end
end
