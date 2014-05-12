class AddForSaleFlagToProducts < ActiveRecord::Migration
  def change
    add_column :products, :for_sale, :boolean, default: true
  end
end
