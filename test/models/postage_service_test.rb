require 'test_helper'

class PostageServiceTest < ActiveSupport::TestCase
  test "should not save without name" do
    postage_service=PostageService.new(valid.except(:name))
    assert_not postage_service.valid?
  end

  test "should save if valid" do
    postage_service=PostageService.new(valid)
    assert postage_service.save
  end

  test "should steal default setting when set" do
    postage_service_default=PostageService.find_by(default: true)
    postage_service=postage_service_default.dup
    postage_service.name="International"
    assert postage_service.save
    postage_service_default.reload
    assert_not postage_service_default.default?
  end

  test "should not allow duplicate names" do
    postage_service=PostageService.create(valid)
    postage_service2=postage_service.dup
    assert_not postage_service2.save
  end

  test "should have 'default' scope" do
    assert_respond_to PostageService, :default
  end

  private
    def valid
      {name: "Some other class", default: false}
    end
end
