class AddDescriptionAndRankToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.text :description
      t.integer :rank, default: 1
      t.remove_index :uid
      t.remove_index :provider
      t.index [:provider, :uid]
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_index [:provider, :uid]
      t.index :provider
      t.index :uid
      t.remove :rank, :description
    end
  end
end
