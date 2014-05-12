require 'test_helper'

class Seller::GiftCardProductsControllerTest < ActionController::TestCase
  test "should have new action for seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
  end

  test "should not have new action for buyer" do
    sign_in users(:buyer)
    get :new
    assert_redirected_to signin_path
  end

  test "should not have new action for anonymous" do
    get :new
    assert_redirected_to signin_path
  end

  test "should have create action for seller" do
    sign_in users(:seller)
    assert_difference "GiftCardProduct.count" do
      post :create, gift_card_product: valid
    end
    assert_redirected_to seller_gift_card_products_path
  end

  test "should have index action" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_select "a[href=#{new_seller_gift_card_product_path}]"
    assert_select "div.panel", GiftCardProduct.count
  end

  test "should not have index action for buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should not have index action for anonymous" do
    get :index
    assert_redirected_to signin_path
  end

  test "should have edit action" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_product)
    get :edit, id: gift_card_product.id
    assert_response :success
  end

  test "should have update action" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_product)
    cost=gift_card_product.unit_cost
    patch :update, id: gift_card_product.id, gift_card_product: valid
    gift_card_product.reload
    assert_not_equal cost, gift_card_product.unit_cost, assigns(:gift_card_product).errors.inspect
    assert_equal "Gift card product updated", flash[:success], flash.inspect
    assert_equal valid[:unit_cost], gift_card_product.unit_cost
    assert_redirected_to seller_gift_card_products_path
  end

  test "should not have update action for buyer" do
    sign_in users(:buyer)
    gift_card_product=products(:gift_card_product)
    cost=gift_card_product.unit_cost
    patch :update, id: gift_card_product.id, gift_card_product: valid
    gift_card_product.reload
    assert_equal cost, gift_card_product.unit_cost
    assert_redirected_to signin_path
  end

  test "should destroy item with no allocations" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_product_no_allocations)
    assert_difference "GiftCardProduct.count", -1 do
      assert_difference "StockLevel.count", -1 do
        delete :destroy, id: gift_card_product.id
      end
    end
    assert_redirected_to seller_gift_card_products_path
  end

  test "should not destroy item with allocations" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_product)
    assert_no_difference "GiftCardProduct.count" do
      delete :destroy, id: gift_card_product.id
    end
    assert_redirected_to seller_gift_card_products_path
  end

  test "should not have destroy action for buyer" do
    sign_in users(:buyer)
    gift_card_product=products(:gift_card_product)
    assert_no_difference "GiftCardProduct.count" do
      delete :destroy, id: gift_card_product.id
    end
    assert_redirected_to signin_path
  end

  test "should have a for_sale checkbox" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_not_for_sale)
    get :edit, id: gift_card_product.id
    assert_select "input[type=checkbox][name='gift_card_product[for_sale]']"
  end

  test "should be able update an item so it's for_sale" do
    sign_in users(:seller)
    gift_card_product=products(:gift_card_not_for_sale)
    assert_difference "GiftCardProduct.for_sale.count" do
      assert_no_difference "GiftCardProduct.count" do
        patch :update, id: gift_card_product.id, gift_card_product: {for_sale: 'true'}
      end
    end
  end


  private
    def valid
      {currency_id: currencies(:gbp).id, unit_cost: 2000}
    end
end
