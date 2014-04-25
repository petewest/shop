class AddPostageCostToOrder < ActiveRecord::Migration
  def change
    add_reference :orders, :postage_cost, index: true
  end
end
