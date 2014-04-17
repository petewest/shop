module CartsHelper
  def current_cart
    begin
      token=Rails.application.message_verifier(:cart_token).verify(cookies[:cart_token]) if !cookies[:cart_token].blank?
      @current_cart||=Cart.find_by_cart_token!(token) if token
    rescue ActiveRecord::RecordNotFound, ActiveSupport::MessageVerifier::InvalidSignature => exception
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
      cookies.permanent[:cart_token]=Rails.application.message_verifier(:cart_token).generate(cart.cart_token)
      @current_cart=cart
    else
      false
    end
  end

end
