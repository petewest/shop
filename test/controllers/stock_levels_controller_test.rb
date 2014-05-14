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
    stock_level=assigns(:stock_level)
    assert_not_nil stock_level
    assert_equal valid[:due_at].inspect, stock_level.due_at.inspect
    assert_equal valid[:start_quantity], stock_level.start_quantity
    assert_equal valid[:start_quantity], stock_level.current_quantity
    assert_equal valid[:expires_at].inspect, stock_level.expires_at.inspect
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

  test "should not edit stock as anon" do
    stock_level=@product.stock_levels.first
    get :edit, id: stock_level.id
    assert_redirected_to signin_path
  end

  test "should not edit stock as buyer" do
    sign_in users(:buyer)
    stock_level=@product.stock_levels.first
    get :edit, id: stock_level.id
    assert_redirected_to signin_path
  end

  test "should edit stock as seller" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    get :edit, id: stock_level.id
    assert_response :success
    assert_select "form" do
      assert_select "input[name='stock_level[start_quantity]']",0
      assert_select "input[name='stock_level[current_quantity]']",0
      assert_select "input[name='stock_level[expires_at]']"
      assert_select "input[type=checkbox][name='stock_level[allow_preorder]']"
    end
  end

  test "should not have update action as buyer" do
    sign_in users(:buyer)
    stock_level=@product.stock_levels.first
    patch :update, id: stock_level.id, stock_level: {allow_preorder: 't'}
    assert_redirected_to signin_path
    assert_not stock_level.reload.allow_preorder
  end

  test "should have update action as seller (html)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    assert_not stock_level.allow_preorder
    patch :update, id: stock_level.id, stock_level: {allow_preorder: 't'}
    assert stock_level.reload.allow_preorder
    assert_equal "Stock level updated", flash[:success]
  end

  test "should have update action as seller (js)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    assert_not stock_level.allow_preorder
    xhr :patch, :update, id: stock_level.id, stock_level: {allow_preorder: 't'}
    assert stock_level.reload.allow_preorder
    assert_equal "Stock level updated", flash[:success]
    assert_template 'update'
  end

  test "should not be able to change quantity" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    quantity_before=stock_level.start_quantity
    patch :update, id: stock_level.id, stock_level: {start_quantity: quantity_before+1}
    assert_equal quantity_before, stock_level.reload.start_quantity
  end

  test "should show edit when failing update (html)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    patch :update, id: stock_level.id, stock_level: {due_at: ""}
    assert_equal "Stock level update failed", flash[:danger]
    assert_template 'edit'
  end

  test "should show edit when failing update (js)" do
    sign_in users(:seller)
    stock_level=@product.stock_levels.first
    xhr :patch, :update, id: stock_level.id, stock_level: {due_at: ""}
    assert_equal "Stock level update failed", flash[:danger]
    assert_template 'edit'
  end
  private
    def valid
      @stock_level||={due_at: 5.days.ago, expires_at: 10.days.from_now, start_quantity: 20, allow_preorder: 'f'}
    end
end
