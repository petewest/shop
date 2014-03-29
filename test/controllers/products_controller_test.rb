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

  test "should not create new product when not signed in" do
    assert_no_difference "Product.count" do
      post :create, product: valid
    end
    assert_response :redirect
  end

  test "should not create new product when signed in as buyer" do
    sign_in users(:buyer)
    assert_no_difference "Product.count" do
      post :create, product: valid
    end
    assert_response :redirect
  end

  test "should create new product when signed in as seller" do
    sign_in users(:seller)
    assert_difference "Product.count" do
      post :create, product: valid
    end
    assert_response :redirect
    assert_not_nil assigns(:product)
    assert_redirected_to assigns(:product)
    assert_equal "New product created", flash[:success]
  end

  test "should create new product when product invalid" do
    sign_in users(:seller)
    assert_no_difference "Product.count" do
      post :create, product: valid.except(:name)
    end
    assert_template :new
    assert_equal "Product creation failed", flash[:danger]
    assert_select ".field_with_errors"
  end



  private
    def valid
      @product||={name: "New product test", description: "Test description", seller: users(:seller)}
    end

end
