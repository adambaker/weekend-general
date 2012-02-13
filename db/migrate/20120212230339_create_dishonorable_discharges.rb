class CreateDishonorableDischarges < ActiveRecord::Migration
  def self.up
    create_table :dishonorable_discharges do |t|
      t.integer :user_id
      t.integer :officer_id
      t.text    :reason

      t.timestamps
    end

    add_index :dishonorable_discharges, :user_id
    add_index :dishonorable_discharges, :officer_id
  end
  def self.down
    remove_index :dishonorable_discharges, :user_id
    remove_index :dishonorable_discharges, :officer_id

    drop_table :dishonorable_discharges
  end
end
