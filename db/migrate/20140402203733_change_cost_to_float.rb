class ChangeCostToFloat < ActiveRecord::Migration
  def change
    change_column :costs, :value, :float
  end
end
