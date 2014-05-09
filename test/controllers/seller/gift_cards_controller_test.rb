require 'test_helper'

class Seller::GiftCardsControllerTest < ActionController::TestCase
  test "should have new action for seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert_select "h1", "Issue new gift card"
    assert_select "form"
    assert_select "select[name='gift_card[redeemer_id]']"
    assert_select "select[name='gift_card[currency_id]']"
    assert_select "input[name='gift_card[unit_cost]']"
    assert_select "label", {text: "Unit cost", count: 0}
    assert_select "input[type=submit]"
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
    assert_difference "current_user.gift_cards_bought.count" do
      assert_difference "users(:buyer).gift_cards_redeemed.count" do
        assert_difference "GiftCard.count" do
          put :create, gift_card: valid
        end
      end
    end
    assert_redirected_to seller_gift_cards_path
  end

  test "should not have create action for buyer" do
    sign_in users(:buyer)
    assert_no_difference "current_user.gift_cards_bought.count" do
      assert_no_difference "users(:buyer).gift_cards_redeemed.count" do
        assert_no_difference "GiftCard.count" do
          put :create, gift_card: valid
        end
      end
    end
    assert_redirected_to signin_path
  end

  test "should not have create action for anonymous" do
    assert_no_difference "users(:buyer).gift_cards_redeemed.count" do
      assert_no_difference "GiftCard.count" do
        put :create, gift_card: valid
      end
    end
    assert_redirected_to signin_path
  end

  test "should have index action for seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
  end

  test "should have edit action for seller" do
    sign_in users(:seller)
    gift_card=GiftCard.first
    get :edit, id: gift_card.id
    assert_response :success
  end

  test "should have update action for seller" do
    sign_in users(:seller)
    gift_card=GiftCard.first
    assert_not_equal valid[:unit_cost], gift_card.start_value
    patch :update, id: gift_card.id, gift_card: valid
    gift_card.reload
    assert_equal valid[:unit_cost], gift_card.start_value, assigns(:gift_card).errors.inspect
    assert_redirected_to seller_gift_cards_path
  end

  test "should filter index action by allocation when asked" do
    sign_in users(:seller)
    gift_card_allocation=allocations(:gift_card_paid)
    get :index, allocation_id: gift_card_allocation.id
    assert_response :success
    assert_not_nil assigns(:gift_cards)
    assert_equal gift_card_allocation.gift_cards, assigns(:gift_cards)
  end

  test "should set user_id when embedded resource" do
    sign_in users(:seller)
    user=users(:buyer)
    get :new, user_id: user.id
    assert_response :success
    assert_select "select[name='gift_card[redeemer_id]']", 0
    assert_select "input[type=hidden][name='gift_card[redeemer_id]'][value=#{user.id}]"
  end


  private
    def valid
      {redeemer_id: users(:buyer).id, currency_id: currencies(:gbp).id, unit_cost: 10000}
    end
end
