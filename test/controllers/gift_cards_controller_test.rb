require 'test_helper'

class GiftCardsControllerTest < ActionController::TestCase

  test "should have index action for buyer" do
    sign_in users(:buyer)
    get :index
    assert_response :success
    assert_select "h1","Gift cards"
    assert_not_nil assigns(:gift_cards)
    assert assigns(:gift_cards).include?(gift_cards(:ten_pounds))
    [:other_user, :no_user, :bought_by_buyer].each do |item|
      assert_not assigns(:gift_cards).include?(gift_cards(item)), "Contains: #{item}"
    end
    assert_select ".gift_card", assigns(:gift_cards).count
    assert_select "a[href=#{redeem_gift_cards_path}]", "Redeem"
  end

  test "should not have index action for anonymous" do
    get :index
    assert_redirected_to signin_path
  end

  test "should have redeem action on collection for buyer" do
    sign_in users(:buyer)
    get :redeem
    assert_response :success
    assert_select "form"
  end

  test "should not have redeem action for anonymous" do
    get :redeem
    assert_redirected_to signin_path
  end

  test "should have redeem action with id param for buyer" do
    sign_in users(:buyer)
    gift_card=gift_cards(:no_user)
    get :redeem, id: gift_card.encoded_token
    assert_response :success
    assert_not_nil assigns(:gift_card)
    assert_equal gift_card, assigns(:gift_card)
    assert_select "input[value='#{gift_card.encoded_token}']"
  end


  test "should have an allocate action for buyer" do
    sign_in users(:buyer)
    gift_card=gift_cards(:no_user)
    patch :allocate, id: gift_card.encoded_token
    assert_redirected_to gift_cards_path
    assert_equal "Gift card redeemed", flash[:success]
    assert_equal users(:buyer), gift_card.reload.redeemer
  end

  test "should warn when attempting to redeem a card purchased by self" do
    sign_in users(:buyer)
    gift_card=gift_cards(:bought_by_buyer)
    get :redeem, id: gift_card.encoded_token
    assert_response :success
    assert_equal "Gift card purchased by you, are you sure you wish to redeem it?", flash[:warning]
  end


  test "should fail gracefully if the token is not found" do
    sign_in users(:buyer)
    gift_card=gift_cards(:no_user)
    patch :allocate, id: gift_card.token
    assert_response :success
    assert_template 'redeem'
    assert_equal "Gift card not found, or redemption code incorrect", flash[:warning]
    assert_nil gift_card.reload.redeemer
    assert_select "input[value='#{gift_card.token}']"
  end

  test "should fail gracefully if the token is already allocated" do
    sign_in users(:buyer)
    gift_card=gift_cards(:other_user)
    patch :allocate, id: gift_card.encoded_token
    assert_response :success, gift_card.reload.redeemer.inspect
    assert_template 'redeem'
    assert_equal "Gift card code has already been redeemed", flash[:warning]
    assert_not_equal users(:buyer), gift_card.reload.redeemer
  end

  test "should not have an allocate action for anonymous" do
    gift_card=gift_cards(:no_user)
    patch :allocate, id: gift_card.encoded_token
    assert_redirected_to signin_path
  end

end
