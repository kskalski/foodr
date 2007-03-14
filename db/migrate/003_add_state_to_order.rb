class AddStateToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :state, :integer, :default => 4, :null => false
  end

  def self.down
    remove_column :orders, :state
  end
end
