class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.references :event
      t.references :user
      t.string :kind
      
      t.timestamps
    end
    
    add_index :rsvps, :event_id
    add_index :rsvps, :user_id
    add_index :rsvps, [:user_id, :kind]
  end

  def self.down
    drop_table :rsvps
  end
end
