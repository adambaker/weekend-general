class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :uid
      
      t.timestamps
    end

    add_index :users, :email, :unique => true
    add_index :users, :provider
    add_index :users, :uid
  end

  def self.down
    drop_table :users
  end
end
