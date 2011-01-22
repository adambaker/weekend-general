class AddThemeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :theme, :string
    add_index :venues, :name
  end

  def self.down
    remove_index :venues, :name
    remove_column :users, :theme
  end
end
