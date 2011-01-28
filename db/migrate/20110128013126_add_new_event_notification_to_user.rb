class AddNewEventNotificationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :new_event, :boolean, default: false
  end

  def self.down
    remove_column :users, :new_event
  end
end
