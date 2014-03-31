module OrdersHelper
  def current_cart
    cookies.permanent[:cart]=[].to_json if cookies[:cart].blank?
    @current_cart=JSON.parse(cookies[:cart])
  end

  def current_cart=(cart)
    cookies[:cart]=cart.to_json
  end

  def add_to_cart(item, quantity)
    cart_now=current_cart
    cart_now<<{line_id: current_cart.count+1, product_id: item.id, quantity: quantity}
    self.current_cart=cart_now
  end

  def line_item_params
    current_cart.map{ |item| ActionController::Parameters.new(item).permit(:product_id, :quantity) }
  end
end
