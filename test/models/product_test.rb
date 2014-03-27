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


  private
    def valid
      @product||={name: "Tshirt!", description: "Description here", seller: users(:seller)}
    end
end
