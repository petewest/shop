require 'test_helper'

class CartControllerTest < ActionController::TestCase
  test "should get cart without login" do
    get :show
    assert_response :success
  end

end
