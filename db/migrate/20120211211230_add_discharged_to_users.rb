class AddDischargedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :discharged, :boolean, default: false
  end

  def self.down
    remove_column :users, :discharged
  end
end
