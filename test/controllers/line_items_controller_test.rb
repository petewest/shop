require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
  test "update these tests now I've learnt a (little) bit more about testing" do
    skip
  end

  test "should create new item when valid" do
    assert_difference "LineItem.count" do
      post :create, line_item: valid
    end
    assert_not_nil assigns(:line_item)
    assert_not assigns(:line_item).new_record?
    assert_equal current_cart.id, assigns(:line_item).order_id
    assert_response :redirect
    assert_redirected_to products_path
  end

  test "should present original item when adding an item already in basket" do
    post :create, line_item: valid
    assert_no_difference "LineItem.count" do
      post :create, line_item: valid
    end
    assert_not_nil assigns(:line_item_duplicate)
  end

  test "should update line item quantity" do
    sign_in users(:buyer)
    line_item=line_items(:one)
    patch :update, id: line_item.id, line_item: valid.merge(quantity: 3)
    assert_response :redirect
    assert_redirected_to products_path
    assert_equal "Cart updated", flash[:success]
    assert_equal 3, assigns(:line_item).quantity
  end

  test "should not update quantity for other users items" do
    sign_in users(:without_cart)
    line_item=users(:buyer).orders.first.line_items.first
    assert_raises ActiveRecord::RecordNotFound do
      patch :update, id: line_item.id, line_item: valid.merge(quantity: 5)
    end
    assert_nil assigns(:line_item)
    line_item.reload
    assert_not_equal 5, line_item.quantity
  end

  test "should allow purchase of product" do
    product=products(:tshirt)
    get :new, product_id: product.id
    assert_response :success
    assert_select "label", product.name
    assert_select ".cart_save_button input[type=submit]"
  end

  test "should show select box for sub_items of master" do
    product=products(:master_product)
    get :new, product_id: product.id
    assert product.sub_products.any?
    assert_response :success
    assert_select '#subproduct-select'
    assert_select ".dropdown-menu" do
      product.sub_products.each do |sub|
        assert_select "a[href=#{product_buy_path(sub)}]"
      end
    end
  end

  test "should warn if product is on pre-order" do
    product=products(:preorder)
    stock_level=stock_levels(:pre_orderable)
    get :new, product_id: product.id
    assert_response :success
    assert_select ".help-block", "This item is available for pre-order with stock due on #{I18n.l(stock_level.due_at.in_time_zone(I18n.t('time.zone')).to_date)}"
    assert_select "input[name='line_item[quantity]']"
  end

  test "should warn if product not for_sale" do
    product=products(:not_for_sale)
    get :new, product_id: product.id
    assert_equal I18n.t('not_for_sale'), flash[:danger]
  end

  private
    def valid
      @line_item||={product_id: products(:tshirt).id, quantity: 1}
    end
end
