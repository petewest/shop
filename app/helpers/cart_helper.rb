module CartHelper
  def current_cart
    @current_cart=Cart.find_by_cart_token(cookies[:cart_token]) if cookies[:cart_token]
    @current_cart||=current_user.carts.first if signed_in? and current_user.carts.any?
    @current_cart||=Cart.new
  end

  def current_cart=(cart)
    cookies[:cart]=cart.to_json
  end

  def add_to_cart(item, quantity)
    #construct item hash
    item_hash={product_id: item.id, quantity: quantity}
    #match keys will be every item in the product hash except quantity
    #this way it'll only increase the quantity when everything else is the same
    match_keys=item_hash.except(:quantity).keys
    cart_now=current_cart
    #do we have an existing item?
    current_key=cart_now.select{|k,v| match_keys.all?{|i| v.symbolize_keys[i]==item_hash[i]}}.keys.first
    #if not, we'll create a new one
    current_key||=SecureRandom.hex(5)
    #add the line item (or add the quantity to the existing one)
    cart_now[current_key]=item_hash.merge((cart_now[current_key] || {}).symbolize_keys.except(*match_keys)){|key, old, new| old+new}
    self.current_cart=cart_now
  end

  def remove_from_cart(line_id)
    self.current_cart=current_cart.except(line_id)
  end

  def line_items_from_cart
    line_item_params.map{|li| LineItem.new(li).copy_cost_from_product }
  end

  def line_item_params
    current_cart.map{ |key, item| ActionController::Parameters.new(item).permit(:product_id, :quantity) }
  end

end
