class CreateEventHosts < ActiveRecord::Migration
  def self.up
    create_table :event_hosts do |t|
      t.references :event
      t.references :user
      
      t.timestamps
    end
    
    add_index :event_hosts, :event_id
    add_index :event_hosts, :user_id
  end

  def self.down
    drop_table :event_hosts
  end
end
