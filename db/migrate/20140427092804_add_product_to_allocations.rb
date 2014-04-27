class AddProductToAllocations < ActiveRecord::Migration
  def change
    add_reference :allocations, :product, index: true
    # Calling .save on each item copies the product ID from the line item
    Allocation.all.map(&:save)
  end
end
