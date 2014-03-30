module CartHelper
  def current_cart
    if @current_cart.nil?
      cookies.permanent[:cart]=[].to_json if cookies[:cart].blank?
      @current_cart=JSON.parse(cookies[:cart])
    end
    @current_cart
  end

  def current_cart=(cart)
    cookies[:cart]=cart.to_json
  end

  def add_to_cart(item, quantity)
    cart_now=current_cart
    cart_now<<{id: item.id, quantity: quantity}
    self.current_cart=cart_now
  end
end
