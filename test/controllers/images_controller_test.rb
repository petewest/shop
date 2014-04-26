require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test "should show image" do
    image=images(:tshirt)
    get :show, id: image.id
    assert_response :success
  end
end
