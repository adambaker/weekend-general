class CreateEventAttendees < ActiveRecord::Migration
  def self.up
    create_table :event_attendees do |t|
      t.references :user
      t.references :event

      t.timestamps
    end

    add_index :event_attendees, :event_id
    add_index :event_attendees, :user_id
  end

  def self.down
    drop_table :event_attendees
  end
end
