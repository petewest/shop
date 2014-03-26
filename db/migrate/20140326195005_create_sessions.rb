class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :user, index: true
      t.string :ip_addr
      t.string :remember_token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :sessions, :remember_token
  end
end
