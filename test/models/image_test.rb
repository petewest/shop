require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test "should not save without product" do
    image=Image.new(valid.except(:product))
    assert_not image.save
  end

  test "should have a main scope" do
    assert_respond_to Image, :main
  end

  test "should respond to image_file_name" do
    image=Image.new
    assert_respond_to image, :image_file_name
  end

  test "should respond to image_content_type" do
    image=Image.new
    assert_respond_to image, :image_content_type
  end

  test "should respond to image_file_size" do
    image=Image.new
    assert_respond_to image, :image_file_size
  end

  test "should respond to image_updated_at" do
    image=Image.new
    assert_respond_to image, :image_updated_at
  end

  private
    def valid
      @image||={product: products(:tshirt)}
    end
end
