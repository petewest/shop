require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  test "should save when valid" do
    address=Address.new(valid)
    assert address.valid?
    assert address.save, "Errors: #{address.errors.inspect}"
  end

  test "should not save without label" do
    address=Address.new(valid.except(:label))
    assert_not address.valid?
    assert_not address.save
  end

  test "should not save without address" do
    address=Address.new(valid.except(:address))
    assert_not address.valid?
    assert_not address.save
  end

  test "should not save without addressable" do
    address=Address.new(valid.except(:addressable))
    assert_not address.valid?
    assert_not address.save
  end

  test "should not allow more than one default billing per addressable" do
    address=Address.new(valid)
    address.save
    address2=Address.new(valid.merge(label: "Work", default_delivery: false, address: "Somewhere else"))
    assert_not address2.save, "Debug: #{address2.inspect}"
  end

  test "should not allow more than one default delivery per user" do
    address=Address.new(valid)
    address.save
    address2=Address.new(valid.merge(label: "Work", default_billing: false, address: "Somewhere else"))
    assert_not address2.save, "Debug: #{address2.inspect}"
  end

  test "should allow multiple non-defaults per addressable" do
    address=Address.new(valid.merge(default_billing: false, default_delivery: false))
    address2=address.dup
    address2.label="Another label"
    assert address.save
    assert address2.save
  end

  test "should have 'delivery' scope" do
    assert_respond_to Address, :delivery
  end

  test "should have 'billing' scope" do
    assert_respond_to Address, :billing
  end

  test "delivery scope should only contain default delivery addresses" do
    addresses=Address.delivery
    assert addresses.include?(addresses(:work))
    assert addresses.all?{ |a| a.default_delivery? }
  end

  test "billing scope should only contain default billing addresses" do
    addresses=Address.billing
    assert addresses.include?(addresses(:home))
    assert addresses.all?{ |a| a.default_billing? }
  end

  test "should not allow duplicate labels per addressable" do
    address=Address.new(valid.merge(default_billing: false, default_delivery: false))
    address2=address.dup
    assert address.save
    assert_not address2.save
  end


  private
    def valid
      @address||={addressable: users(:without_addresses), label: "Home", default_billing: true, default_delivery: true, address: "Number one nostreet close\nHometown\nSAD ACT"}
    end
end
