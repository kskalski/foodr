class Createdby < ActiveRecord::Migration
  def self.up
    add_column :orders, :created_by, :integer
    add_column :order_positions, :created_by, :integer
  end

  def self.down
    remove_column :orders, :created_by, :integer
    remove_column :order_positions, :created_by, :integer
  end
end
