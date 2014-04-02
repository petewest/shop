class AddIndexToIsoCode < ActiveRecord::Migration
  def change
    add_index :currencies, :iso_code, unique: true
  end
end
