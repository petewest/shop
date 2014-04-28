class CreatePostageServices < ActiveRecord::Migration
  def change
    create_table :postage_services do |t|
      t.string :name
      t.boolean :default, default: false

      t.timestamps
    end
  end
end
