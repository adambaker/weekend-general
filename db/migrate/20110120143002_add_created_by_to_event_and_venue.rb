class AddCreatedByToEventAndVenue < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.integer :created_by
      t.index :date
      t.index :venue_id
      t.index [:date, :price]
      t.index :created_at
      t.index :updated_at
    end
    
    change_table :venues do |t|
      t.integer :created_by
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :created_by
      [:date, :venue_id, [:date, :price], :created_at, :updated_at]
        .each do |index|
          t.remove_index index
        end
    end
    
    remove_column :venues, :created_by
  end
end
