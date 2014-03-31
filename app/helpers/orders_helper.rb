module OrdersHelper
  def line_item_params
    current_cart.map{ |key, item| ActionController::Parameters.new(item).permit(:product_id, :quantity) }
  end
end
