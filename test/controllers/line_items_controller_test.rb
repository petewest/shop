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

  private
    def valid
      @line_item||={product_id: products(:tshirt).id, quantity: 1}
    end
end
