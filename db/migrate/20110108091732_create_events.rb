class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :time
      t.integer :price
      t.references :venue
      t.string :address
      t.string :city
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
