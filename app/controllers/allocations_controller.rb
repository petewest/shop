class AllocationsController < ApplicationController
  before_action :signed_in_seller

  def index
    @allocations=Allocation.includes(:product)
    if params[:by_product]
      a_table=Allocation.arel_table
      # Combine the columns we want combining
      @allocations=@allocations.select(a_table[:quantity].sum.as('quantity'), a_table[:product_id])
      # Group by product id
      @allocations=@allocations.group(a_table[:product_id])
    end
  end

end
