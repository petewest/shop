require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  test "should redirect without login" do
    get :index
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should show page after login" do
    sign_in users(:buyer)
    get :index
    assert_response :success
  end

  test "should show a list of all the users orders" do
    sign_in users(:buyer)
    order_count=users(:buyer).orders.count
    cart_count=users(:buyer).orders.cart.count
    line_item_count=users(:buyer).orders.map(&:line_items).map(&:count).sum
    get :index
    assert_not_nil assigns(:orders)
    assert_not assigns(:orders).include?(orders(:cart_without_user))
    assert_equal order_count, assigns(:orders).count
    assert_select "div.order_list" do
      assert_select ".order_item", order_count
      assert_select ".order_status_cart", cart_count
      assert_select ".order_summary div.order_line_item", line_item_count
      assert_select "form", cart_count
    end
  end

  test "should set current cart to selected order" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=users(:buyer).carts.last
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal users(:buyer).carts.first, current_cart
    assert_equal cart, current_cart
  end

  test "should not set current cart to selected order when it belongs to someone else" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=orders(:cart_for_other_user)
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal cart, current_cart
  end

  test "should not set current cart to selected order when it doesn't belong to anyone" do
    sign_in users(:buyer)
    self.current_cart=users(:buyer).carts.first
    @current_cart=nil
    cart=orders(:cart_without_user)
    patch :set_current, id: cart.id
    assert_redirected_to cart_url
    assert_not_equal cart, current_cart
  end

  test "should not resume order not in cart status" do
    sign_in users(:buyer)
    cart=orders(:placed)
    patch :set_current, id: cart.id
    assert_not_equal cart.cart_token, cookies[:cart_token]
  end

  test "should redirect to checkout" do
    sign_in users(:buyer)
    cart=users(:buyer).carts.first
    patch :set_current, id: cart.id, submit: "Checkout"
    assert_redirected_to checkout_url
  end

  test "should view order" do
    sign_in users(:buyer)
    order=users(:buyer).orders.first
    get :show, id: order.id
    assert_response :success
  end

  test "should not get order" do
    sign_in users(:seller)
    order=users(:buyer).orders.first
    assert_raises ActiveRecord::RecordNotFound do
      get :show, id: order.id
    end
  end

  test "should get pay page" do
    sign_in users(:buyer)
    order=orders(:placed)
    get :pay, id: order.id
    assert_response :success
    assert_select "h1", "Payment"
    assert_select "form"
  end

  test "should not get pay page when not placed" do
    sign_in users(:buyer)
    order=orders(:cart)
    get :pay, id: order.id
    assert_response :redirect
  end

  test "should not get pay page when other user" do
    sign_in users(:buyer)
    order=orders(:cart_for_other_user)
    assert_raises ActiveRecord::RecordNotFound do
      get :pay, id: order.id
    end
  end

  test "should not get pay page when anonymous" do
    order=orders(:placed)
    get :pay, id: order.id
    assert_response :redirect
    assert_redirected_to signin_path
  end

  test "should not process without stripeToken" do
    sign_in users(:buyer)
    order=orders(:placed)
    patch :update, id: order.id
    assert_redirected_to pay_order_path(order)
    assert_equal "Missing payment data, please try again", flash[:warning]
  end

  test "should not be able to pay for an order not in placed status" do
    sign_in users(:buyer)
    order=orders(:cart)
    patch :update, id: order.id, stripeToken: "dummy_token"
    assert_template 'pay'
    assert_equal "Could not process order", flash[:danger]
  end

  test "should not be able to pay for an order that already has a charge reference" do
    sign_in users(:buyer)
    order=orders(:placed)
    order.stripe_charge_reference="dummy charge reference"
    order.save
    patch :update, id: order.id, stripeToken: "dummy_token"
    assert_redirected_to order_path(order)
    assert_equal "Order already paid", flash[:warning]
  end

  test "should not be able to update when other user" do
    sign_in users(:buyer)
    order=orders(:cart_for_other_user)
    assert_raises ActiveRecord::RecordNotFound do
      patch :update, id: order.id
    end
  end

  test "should cancel order" do
    sign_in users(:buyer)
    order=orders(:placed)
    patch :cancel, id: order.id
    order.reload
    assert order.cancelled?
    assert_redirected_to orders_path
  end

  test "should generate buyer and seller emails on order cancellation" do
    user=users(:buyer)
    sign_in user
    order=orders(:placed)
    assert_difference "ActionMailer::Base.deliveries.count", 2 do
      patch :cancel, id: order.id
    end
    mails=ActionMailer::Base.deliveries.last(2)
    assert_not mails.select{|m| m.to.include?(user.email)}.empty?
    assert_not mails.select{|m| m.to==Seller.pluck(:email)}.empty?
  end


  test "should not cancel other users order" do
    sign_in users(:seller)
    order=orders(:placed)
    assert_raises ActiveRecord::RecordNotFound do
      patch :cancel, id: order.id
    end
    order.reload
    assert_not order.cancelled?
  end

  test "should not cancel dispatched order" do
    sign_in users(:buyer)
    order=orders(:placed)
    #Force status to dispatched
    order.dispatched!
    assert_raises ActiveRecord::RecordInvalid do
      patch :cancel, id: order.id
    end
    order.reload
    assert_not order.cancelled?
  end





end
