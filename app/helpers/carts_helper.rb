module CartsHelper
  def current_cart
    begin
      token=Rails.application.message_verifier(:cart_token).verify(cookies[:cart_token]) if !cookies[:cart_token].blank?
      @current_cart||=Cart.find_by_cart_token!(token) if token
    rescue ActiveRecord::RecordNotFound, ActiveSupport::MessageVerifier::InvalidSignature => exception
      self.current_cart=nil
    end
    @current_cart||=current_user.try(:carts).try(:first)
    @current_cart||=Cart.new(user: current_user)
    @current_cart=Cart.new(user: current_user) if @current_cart.user && !current_user?(@current_cart.user)
    @current_cart
  end

  def current_cart=(cart)
    if cart.nil?
      cookies.delete(:cart_token)
      @current_cart=cart
    elsif !cart.new_record? or cart.save
      cookies.permanent[:cart_token]=Rails.application.message_verifier(:cart_token).generate(cart.cart_token)
      @current_cart=cart
    else
      false
    end
  end

end
