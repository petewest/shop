class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.references :costable, polymorphic: true, index: true
      t.references :currency, index: true
      t.integer :value

      t.timestamps
    end
  end
end
