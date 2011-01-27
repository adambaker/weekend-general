class AddTrackingNotificationOptionsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :track_host, default: true
      t.boolean :track_attend, default: true
      t.boolean :track_maybe, default: false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :track_host, :track_attend, :track_maybe
    end
  end
end
