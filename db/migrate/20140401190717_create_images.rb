class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :product, index: true
      t.boolean :main

      t.timestamps
    end
  end
end
