require 'test_helper'

class OrderAddressTest < ActiveSupport::TestCase
  test "should create if valid" do
    o_a=OrderAddress.new(valid)
    assert o_a.save
  end

  private
    def valid
      @address||={source_address: users(:buyer).addresses.delivery.first, address: "Copied address"}
    end
end
