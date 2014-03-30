module CartHelper
  def current_cart
    if @current_cart.nil?
      cookies[:cart]=[] if cookies[:cart].nil?
      @current_cart=cookies[:cart]
    end
    @current_cart
  end

  def add_to_cart(item, quantity)
    self.current_cart<<{id: item.id, quantity: quantity}
  end
end
