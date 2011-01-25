class AddReminderPrefsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :attend_reminder, default: true
      t.boolean :maybe_reminder, default: false
      t.boolean :host_reminder, default: false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :attend_reminder, :maybe_reminder, :host_reminder
    end 
  end
end
