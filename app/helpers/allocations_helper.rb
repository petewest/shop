module AllocationsHelper

  def allocation_filter
    Hash(
      by_product: true,
      order_status: Order.statuses.keys
      )
  end
end
