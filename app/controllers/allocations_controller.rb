class AllocationsController < ApplicationController
  before_action :signed_in_seller

  def index
    allocation_table=Allocation.arel_table
    order_table=Order.arel_table
    @allocations=Allocation.includes(:product)
    @allocations=@allocations.where(allocation_table[:product_id].eq(params[:product_id])) if params[:product_id]
    #If we're only looking for orders of a certain status, check here
    @allocations=@allocations.joins(:order).where(order_table[:status].eq(Order.statuses[params[:order_status]])) if params[:order_status] and params[:order_status].in?(Order.statuses.keys)
    if params[:by_product]
      # Combine the columns we want combining
      @allocations=@allocations.select(allocation_table[:quantity].sum.as('quantity'), allocation_table[:product_id])
      # Group by product id
      @allocations=@allocations.group(allocation_table[:product_id])
    end
  end

end
