class CreateSuppliersUsers < ActiveRecord::Migration
  def self.up
    create_table "suppliers_users", :force => true, :id => false  do |t|
	t.column :supplier_id, :integer, :null => false 
	t.column :user_id, :integer, :null => false 
    end
  end

  def self.down
    drop_table "suppliers_users"
  end
end
