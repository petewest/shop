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

  test "should show product info" do
    product=products(:tshirt)
    get :show, id: product.id
    assert_response :success
    assert_not_nil assigns(:product)
    assert_select "h1", product.name
    assert_select "div.product_page_description", product.description
  end

  test "should have seller actions for seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    get :show, id: product.id
    assert_select "h4", "Seller actions"
    assert_select "a[href=#{edit_product_path(product)}]"
    assert_select "a[href=#{product_path(product)}]", "Delete"
  end

  test "should not have seller actions for buyer" do
    sign_in users(:buyer)
    product=products(:tshirt)
    get :show, id: product.id
    assert_select "a[href=#{edit_product_path(product)}]", 0
  end

  test "should not have seller actions for not logged in user" do
    product=products(:tshirt)
    get :show, id: product.id
    assert_select "a[href=#{edit_product_path(product)}]", 0
  end

  test "should not delete item for not logged in user" do
    product=products(:tshirt)
    assert_no_difference "Product.count" do
      delete :destroy, id: product.id
    end
    assert_response :redirect
  end

  test "should not delete item for buyer user" do
    sign_in users(:buyer)
    product=products(:tshirt)
    assert_no_difference "Product.count" do
      delete :destroy, id: product.id
    end
    assert_response :redirect
  end

  test "should delete item for not seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    assert_difference "Product.count", -1 do
      delete :destroy, id: product.id
    end
    assert_response :redirect
  end



  private
    def valid
      @product||={name: "New product test", description: "Test description", seller: users(:seller)}
    end

end
