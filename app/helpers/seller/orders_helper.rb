module Seller::OrdersHelper
  def seller_orders_filter
    Hash(
      order_status: Order.statuses.keys,
      status_pending: Order.allowed_status_flows.values.flatten.uniq
      )
  end
end
