class AddPostageServiceToPostageCosts < ActiveRecord::Migration
  def change
    add_reference :postage_costs, :postage_service, index: true
    add_reference :orders, :postage_service, index: true
  end
end
