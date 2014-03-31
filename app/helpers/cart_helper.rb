module CartHelper
  def current_cart
    cookies.permanent[:cart]={}.to_json if cookies[:cart].blank?
    @current_cart=JSON.parse(cookies[:cart])
  end

  def current_cart=(cart)
    cookies[:cart]=cart.to_json
  end

  def add_to_cart(item, quantity)
    cart_now=current_cart
    cart_now[SecureRandom.hex(5)]={product_id: item.id, quantity: quantity}
    self.current_cart=cart_now
  end

  def remove_from_cart(line_id)
    self.current_cart=current_cart.except(line_id)
  end

end
