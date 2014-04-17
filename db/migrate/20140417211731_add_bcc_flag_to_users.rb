class AddBccFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bcc_on_email, :boolean, default: false
  end
end
