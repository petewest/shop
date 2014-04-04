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
      puts "Setting cookie"
      cookies.permanent[:cart_token]=cart.cart_token
      cart
    else
      puts "Save failed"
      false
    end
  end

  def add_to_cart(item_hash)
    #do we have an existing item?
    current_line_item=current_cart.line_items.find_or_initialize_by(item_hash.except(:quantity))
    current_line_item.assign_attributes(quantity: item_hash[:quantity])
    current_line_item.save if !current_line_item.new_record?
    self.current_cart=current_cart
  end

end
