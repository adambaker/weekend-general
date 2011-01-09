class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :url
      t.string :text
      t.references :event
    end
  end

  def self.down
    drop_table :links
  end
end
