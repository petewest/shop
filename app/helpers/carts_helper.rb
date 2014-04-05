module CartsHelper
  def current_cart
    begin
      @current_cart||=Cart.find_by_cart_token!(cookies[:cart_token]) if cookies[:cart_token]
    rescue ActiveRecord::RecordNotFound => exception
      cookies[:cart_token]=nil
    end
    @current_cart||=current_user.carts.first if signed_in? and current_user.carts.any?
    @current_cart||=Cart.new(user: current_user)
    @current_cart=Cart.new(user: current_user) if @current_cart.user and @current_cart.user!=current_user
    @current_cart
  end

  def current_cart=(cart)
    if cart.nil?
      cookies[:cart_token]=nil
      @current_cart=cart
    elsif !cart.new_record? or cart.save
      cookies.permanent[:cart_token]=cart.cart_token
      @current_cart=cart
    else
      false
    end
  end

end
