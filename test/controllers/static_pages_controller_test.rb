require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "h1", "Welcome to the shop"
    assert_select "title", "Shop!"
    assert_select "nav"
    assert_select "a[href=#{root_url}]", "Shop!"
    assert_select "a[href=#{signin_path}]", "Sign in"
    assert_select "a[href=#{signup_path}]", "Sign up"
    #shouldn't have buyer or seller links
    buyer_links.each{|link| assert_select "a[href=#{link}]",0 }
    seller_links.each{|link| assert_select "a[href=#{link}]",0 }
  end

  test "should have different links when signed in as buyer" do
    sign_in users(:buyer)
    get :home
    assert_select "a[href=#{signin_path}]", 0
    assert_select "a[href=#{signup_path}]", 0
    assert_select "a", "My account"
    #should have buyer links
    buyer_links.each{|link| assert_select "a[href=#{link}]" }
    #shouldn't have seller links
    seller_links.each{|link| assert_select "a[href=#{link}]",0 }
  end

  test "should show seller menu when logged in as seller" do
    sign_in users(:seller)
    get :home
    assert_select "a", "Seller"
    #Should have seller links
    seller_links.each{|link| assert_select "a[href=#{link}]" }
    #should also have buyer links
    buyer_links.each{|link| assert_select "a[href=#{link}]" }
  end


  def seller_links
    [new_product_path, currencies_path, postage_services_path, seller_orders_path, seller_products_path, charges_path, allocations_path, seller_users_path, seller_gift_card_products_path]
  end

  def buyer_links
    [signout_path, orders_path, addresses_path, my_account_path, password_user_path, gift_card_products_path]
  end

end
