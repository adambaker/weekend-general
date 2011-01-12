class CreateEventMaybes < ActiveRecord::Migration
  def self.up
    create_table :event_maybes do |t|
      t.references :user
      t.references :event

      t.timestamps
    end
    
    add_index :event_maybes, :user_id
    add_index :event_maybes, :event_id
  end

  def self.down
    drop_table :event_maybes
  end
end
