require 'test_helper'

class SellerTest < ActiveSupport::TestCase
  test "should be a Seller and a User" do
    seller=Seller.new
    assert seller.is_a? Seller
    assert seller.is_a? User
  end
end
