require 'test_helper'

class SubProductTest < ActiveSupport::TestCase
  test "should save if valid" do
    sub_product=SubProduct.new(valid)
    assert sub_product.save
  end

  test "should not save without master product" do
    sub_product=SubProduct.new(valid.except(:master_product))
    assert_not sub_product.save
  end

  test "should delete sub_product when master is destroyed" do
    sub_product=SubProduct.new(valid)
    product=sub_product.master_product
    sub_product.save
    assert_difference "SubProduct.count",-1 do
      product.destroy
    end
  end

  test "should give product.name when requesting name" do
    sub_product=products(:sub_product)
    assert_equal "#{sub_product.master_product.name} - #{sub_product[:name]}", sub_product.name
  end



  private
    def valid
      @sub_product||={name: "Small", description: "Description here", seller: users(:seller), currency: currencies(:gbp), unit_cost: 200, weight: 20, master_product: products(:tshirt)}
    end
end
