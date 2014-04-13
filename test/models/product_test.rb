require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "should respond to seller" do
    product=Product.new
    assert_respond_to product, :seller
  end

  test "should save when valid" do
    product=Product.new(valid)
    assert_not_nil product.save
  end

  test "should not be valid without seller" do
    product=Product.new(valid.except(:seller))
    assert_not product.valid?
  end

  test "should not save when seller isn't seller" do
    assert_raises ActiveRecord::AssociationTypeMismatch do
      product=Product.new(valid.merge(seller: users(:buyer)))
    end
  end

  test "should not be valid without name" do
    product=Product.new(valid.except(:name))
    assert_not product.valid?
  end

  test "should respond to line_items" do
    product=Product.new
    assert_respond_to product, :line_items
  end

  test "should respond to orders" do
    product=Product.new
    assert_respond_to product, :orders
  end

  test "should respond to purchased_by" do
    product=Product.new
    assert_respond_to product, :purchased_by
  end

  test "should respond to dispatched_orders" do
    product=Product.new
    assert_respond_to product, :dispatched_orders
  end

  test "should contain line items" do
    product=products(:tshirt)
    assert_not_nil product.line_items
    assert_equal [line_items(:one)], product.line_items
  end

  test "should respond to weight" do
    product=Product.new
    assert_respond_to product, :weight
  end

  test "should not allow non-numeric weights" do
    product=Product.new(valid.merge(weight: "elephant"))
    assert_not product.valid?
  end

  test "should allow decimal weights" do
    product=Product.new(valid.merge(weight: 23.54))
    assert product.save
    product.reload
    assert_equal 23.54, product.weight
  end

  test "should save without weight" do
    product=Product.new(valid.except(:weight))
    assert product.valid?
  end

  test "deleting a product should remove its stock levels" do
    product=products(:tshirt)
    stock=product.stock_levels
    stock_count=stock.count
    assert stock_count>0
    assert_difference "StockLevel.count", -1*stock_count do
      product.destroy
    end
  end

  test "should have current_stock association" do
    assert_respond_to Product.new, :current_stock
  end

  test "should respond to sub_products" do
    product=Product.new
    assert_respond_to product, :sub_products
  end


  private
    def valid
      @product||={name: "Tshirt!", description: "Description here", seller: users(:seller), currency: currencies(:gbp), unit_cost: 200, weight: 20}
    end
end
