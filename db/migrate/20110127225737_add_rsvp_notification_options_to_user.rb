class AddRsvpNotificationOptionsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :host_rsvp, default: true
      t.boolean :attend_rsvp, default: false
      t.boolean :maybe_rsvp, default: false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :host_rsvp, :attend_rsvp, :maybe_rsvp
    end
  end
end
