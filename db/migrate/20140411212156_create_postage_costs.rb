class CreatePostageCosts < ActiveRecord::Migration
  def change
    create_table :postage_costs do |t|
      t.float :from_weight
      t.float :to_weight
      t.integer :cost
      t.references :currency, index: true

      t.timestamps
    end
  end
end
