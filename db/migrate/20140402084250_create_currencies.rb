class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :iso_code
      t.string :symbol
      t.integer :decimal_places

      t.timestamps
    end
  end
end
