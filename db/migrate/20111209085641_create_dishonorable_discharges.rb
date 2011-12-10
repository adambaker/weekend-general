class CreateDishonorableDischarges < ActiveRecord::Migration
  def self.up
    create_table :dishonorable_discharges do |t|
      t.string :email
      t.string :provider
      t.string :uid
      t.integer :officer
      t.text :reason

      t.timestamps
    end

    change_table :dishonorable_discharges do |t|
      t.index :email
      t.index [:provider, :uid]
    end
  end

  def self.down
    drop_table :dishonorable_discharges
  end
end
