require 'test_helper'

class OrderAddressTest < ActiveSupport::TestCase
  test "should create if valid" do
    o_a=OrderAddress.new(valid)
    assert o_a.save
  end

  test "should not save without source address" do
    o_a=OrderAddress.new(valid.except(:source_address))
    assert_not o_a.save
  end

  test "should copy source address to this record" do
    o_a=OrderAddress.new(valid.except(:address))
    assert o_a.save
    assert_equal o_a.source_address.address, o_a.address
  end


  private
    def valid
      @address||={source_address: users(:buyer).addresses.delivery.first, address: "Copied address"}
    end
end
