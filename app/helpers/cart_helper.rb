module CartHelper
  def current_cart
    cookies.permanent[:cart]={}.to_json if cookies[:cart].blank?
    @current_cart=JSON.parse(cookies[:cart])
  end

  def current_cart=(cart)
    cookies[:cart]=cart.to_json
  end

  def add_to_cart(item, quantity)
    item_hash={product_id: item.id, quantity: quantity}
    match_keys=item_hash.except(:quantity).keys
    cart_now=current_cart
    current_key=cart_now.select{|k,v| match_keys.all?{|i| v.symbolize_keys[i]==item_hash[i]}}.keys.first
    current_key||=SecureRandom.hex(5)
    cart_now[current_key]=item_hash.merge((cart_now[current_key] || {}).symbolize_keys.except(*match_keys)){|key, old, new| old+new}
    self.current_cart=cart_now
  end

  def remove_from_cart(line_id)
    self.current_cart=current_cart.except(line_id)
  end

end
