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
    assert_select "select.currency", 1
    assert_select "input[name='product[weight]']"
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
    assert_equal users(:seller), assigns(:product).seller
    assert_equal "New product created", flash[:success]
  end

  test "should not create new product when product invalid" do
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
    assert_nil flash[:warning]
    assert_select "a[href='#{product_buy_path(product)}']"
  end

  test "should have seller actions for seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    get :show, id: product.id
    assert_select "h4", "Seller actions"
    assert_select "a[href=#{edit_product_path(product)}]"
    assert_select "a[href=#{product_path(product)}]", "Delete"
    assert_select "a[href=#{product_stock_levels_path(product)}]"
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

  test "should delete item for seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    assert_difference "Product.count", -1 do
      delete :destroy, id: product.id
    end
    assert_response :redirect
  end

  test "should allow seller to edit" do
    sign_in users(:seller)
    product=products(:tshirt)
    get :edit, id: product.id
    assert_response :success
    assert_select "h1", "Edit #{product.name}"
    assert_select "form"
    assert_select "input[name='product[weight]']"
  end

  test "should not allow buyer to edit" do
    sign_in users(:buyer)
    product=products(:tshirt)
    get :edit, id: product.id
    assert_response :redirect
    assert_select "form", 0
  end

  test "should update for seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    old_name=product.name
    patch :update, id: product.id, product: {name: "new name"}
    product.reload
    assert_not_nil assigns(:product)
    assert_equal "new name", product.name
    assert_not_equal old_name, product.name
    assert_redirected_to product
  end

  test "should not update for buyer" do
    sign_in users(:buyer)
    product=products(:tshirt)
    old_name=product.name
    patch :update, id: product.id, product: {name: "new name"}
    product.reload
    assert_not_equal "new name", product.name
    assert_equal old_name, product.name
    assert_response :redirect
  end

  test "should not update with invalid details" do
    sign_in users(:seller)
    product=products(:tshirt)
    old_name=product.name
    patch :update, id: product.id, product: {name: ""}
    product.reload
    assert_equal old_name, product.name
    assert_template :edit
  end

  test "should not change seller" do
    sign_in users(:seller)
    product=products(:tshirt)
    old_name=product.name
    patch :update, id: product.id, product: {name: product.name, description: product.description, seller_id: users(:seller2).id}
    product.reload
    assert_not_equal users(:seller2), product.seller
    assert_equal users(:seller), product.seller
  end

  test "should strip thousand seperator from cost" do
    sign_in users(:seller)
    post :create, product: valid.merge(currency_id: currencies(:gbp).id, unit_cost: "2#{I18n.t("number.format.delimiter")}000")
    assert assigns(:product)
    assert_equal 2000, assigns(:product).unit_cost
  end

  test "should have id modal" do
    get :index
    assert_response :success
    assert_select "div#modal"
  end

  test "should set weight" do
    sign_in users(:seller)
    post :create, product: valid.merge(weight: "50")
    assert_equal 50, assigns(:product).weight
  end

  test "should update weight" do
    sign_in users(:seller)
    product=products(:tshirt)
    post :update, id: product.id, product: {weight: "50"}
    assert_equal 50, assigns(:product).weight
  end

  test "should create a SubProduct item when given a master_product_id" do
    sign_in users(:seller)
    product=products(:tshirt)
    assert_difference "SubProduct.count" do
      assert_difference "product.sub_products.count" do
        post :create, product: valid.merge(master_product_id: product.id)
      end
    end
  end

  test "should not contain items not for sale in index" do
    # scroll through each page
    page=nil
    begin
      get :index, page: page
      assert assigns(:products).all?(&:for_sale?)
    end while page=assigns(:products).next_page
  end

  test "should be able to get show page for product no longer for sale, but should warn" do
    product=products(:not_for_sale)
    get :show, id: product.id
    assert_equal "Product not for sale", flash[:warning]
    assert_select "a[href='#{product_buy_path(product)}']", 0
  end

  private
    def valid
      @product||={name: "New product test", description: "Test description", currency_id: currencies(:gbp).id, unit_cost: 200}
    end

end
