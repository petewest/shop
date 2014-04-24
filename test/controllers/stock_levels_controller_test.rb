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
    assert_select "tr", @product.stock_levels.count+1
    assert_select "a[href='#{stock_level_path(@product.stock_levels.first)}'][data-method='delete']"
    assert_select "a[href=#{stock_level_orders_path(@product.stock_levels.first)}]"
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

  test "should create new stock when valid (html)" do
    sign_in users(:seller)
    assert_difference "StockLevel.count" do
      assert_difference "@product.stock_levels.count" do
        post :create, product_id: @product.id, stock_level: valid
      end
    end
    assert_redirected_to product_stock_levels_url(@product)
  end

  test "should create new stock when valid (js)" do
    sign_in users(:seller)
    assert_difference "StockLevel.count" do
      assert_difference "@product.stock_levels.count" do
        xhr :post, :create, product_id: @product.id, stock_level: valid
      end
    end
    assert_template 'create'
  end


  test "should create pre-orderable stock" do
    sign_in users(:seller)
    assert_difference "StockLevel.current.count" do
      post :create, product_id: @product.id, stock_level: valid.merge(due_at: 3.days.from_now, allow_preorder: 't')
    end
  end

  test "should allow deletion of stock (html)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    assert_difference "StockLevel.count", -1 do
      delete :destroy, id: stock_level.id
    end
    assert_redirected_to product_stock_levels_url(@product)
  end

  test "should allow deletion of stock (js)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    assert_difference "StockLevel.count", -1 do
      xhr :delete, :destroy, id: stock_level.id
    end
    assert_template 'destroy'
  end


  private
    def valid
      @stock_level||={due_at: 5.days.ago, start_quantity: 20, allow_preorder: 'f'}
    end
end
