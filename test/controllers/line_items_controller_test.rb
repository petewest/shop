require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase
  test "should show new page" do
    get :new
    assert_response :success
  end
end
