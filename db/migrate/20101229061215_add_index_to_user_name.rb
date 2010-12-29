class AddIndexToUserName < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.index :name
    end
  end

  def self.down
    remove_index :users, :name
  end
end
