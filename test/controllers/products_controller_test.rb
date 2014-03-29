require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  test "should be able to browse to product index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should contain a list of products" do
    get :index
    assert_not_nil assigns(:products)
    item_count=[Product.count, 30].min
    assert_select "div.product_list div", item_count do
      assert_select "a"
    end
  end

  test "should not get new page without being logged in" do
    get :new
    assert_response :redirect
    assert_redirected_to signin_path
    assert_equal "Please sign in to a seller account", flash[:notice]
  end

  test "should not get new page when signed in as buyer" do
    sign_in users(:buyer)
    get :new
    assert_response :redirect
    assert_redirected_to signin_path
    assert_equal "Please sign in to a seller account", flash[:notice]
  end

  test "should get new page when signed in as seller" do
    sign_in users(:seller)
    get :new
    assert_response :success
    assert_not_nil assigns(:product)
    assert_select "h1", "Create new product"
    assert_select "form"
  end

end
