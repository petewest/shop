require 'test_helper'

class PostageCostsControllerTest < ActionController::TestCase
  test "should not be accessible without login" do
    get :index
    assert_redirected_to signin_path
  end


  test "should not be accessible with buyer" do
    sign_in users(:buyer)
    get :index
    assert_redirected_to signin_path
  end

  test "should be accessible with seller" do
    sign_in users(:seller)
    get :index
    assert_response :success
    assert_not_nil assigns(:postage_costs)
    assert_select "table"
    assert_select "a[href=#{new_postage_cost_path}]"
  end

  test "should have an edit action" do
    sign_in users(:seller)
    postage_cost=PostageCost.first
    get :edit, id: postage_cost.id
    assert_response :success
    assert_not_nil assigns(:postage_cost)
    assert_select "form"
  end

  test "should update postage cost" do
    sign_in users(:seller)
    postage_cost=PostageCost.first
    assert_not_equal postage_cost.from_weight, valid[:from_weight]
    assert_not_equal postage_cost.to_weight, valid[:to_weight]
    assert_not_equal postage_cost.unit_cost, valid[:unit_cost]
    assert_not_equal postage_cost.currency_id, valid[:currency_id]
    patch :update, id: postage_cost.id, postage_cost: valid
    assert_not_nil assigns(:postage_cost)
    assert_redirected_to postage_costs_url
    postage_cost.reload
    assert_equal valid[:from_weight], postage_cost.from_weight
    assert_equal valid[:to_weight], postage_cost.to_weight
    assert_equal valid[:unit_cost], postage_cost.unit_cost
    assert_equal valid[:currency_id], postage_cost.currency_id
  end

  test "should have new action" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert_not_nil assigns(:postage_cost)
    assert assigns(:postage_cost).new_record?
    assert_select "form"
  end

  test "should create postage cost" do
    sign_in users(:seller)
    assert_difference "PostageCost.count" do
      post :create, postage_cost: valid
    end
    assert_redirected_to postage_costs_url
  end

  test "should destroy postage cost" do
    sign_in users(:seller)
    postage_cost=PostageCost.first
    assert_difference "PostageCost.count", -1 do
      delete :destroy, id: postage_cost.id
    end
    assert_redirected_to postage_costs_url
  end


  private
    def valid
      @postage_cost||={from_weight: 50, to_weight: 80, currency_id: currencies(:usd).id, unit_cost: 80}
    end
end
