require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
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

  private
    def valid
      @line_item||={buyable_id: products(:tshirt).id, buyable_type: "Product", quantity: 1, currency: currencies(:gbp), cost: 20}
    end
end
