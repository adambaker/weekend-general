class CreateTrails < ActiveRecord::Migration
  def self.up
    create_table :trails do |t|
      t.integer :tracker_id
      t.integer :target_id

      t.timestamps
    end
    
    add_index :trails, :tracker_id
    add_index :trails, :target_id
  end

  def self.down
    remove_index :trails, :tracker_id
    remove_index :trails, :target_id
    drop_table :trails
  end
end
