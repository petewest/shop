module CartHelper
  def current_cart
    begin
      @current_cart||=Cart.find_by_cart_token!(cookies[:cart_token]) if cookies[:cart_token]
    rescue ActiveRecord::RecordNotFound => exception
      cookies[:cart_token]=nil
    end
    @current_cart||=current_user.carts.first if signed_in? and current_user.carts.any?
    @current_cart||=Cart.new
  end

  def current_cart=(cart)
    if !cart.new_record? or cart.save
      cookies.permanent[:cart_token]=cart.cart_token
      cart
    else
      false
    end
  end

end
