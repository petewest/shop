class AddDefaultFalseToMainImage < ActiveRecord::Migration
  def change
    change_column :images, :main, :boolean, default: false
  end
end
