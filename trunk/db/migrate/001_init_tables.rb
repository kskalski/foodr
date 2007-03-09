class InitTables < ActiveRecord::Migration
  def self.up
    create_table :orders, :force => true do |t|
      t.column :delivery_date, :date
      t.column :supplier, :string
      t.column :orderer, :string
      t.column :comments, :text
    end
      
#    create_table :supplier, :force => true do |t|
#      t.column :name, :string
#      t.column :phone, :string
#      t.column :email, :string
#    end
    
    create_table :order_positions, :force => true do |t|
      t.column :order_id, :integer
      t.column :receiver_email, :string
      t.column :material, :string
      t.column :debt_for_orderer, :float
    end
  end

  def self.down
    drop_table :order_positions 
    drop_table :orders
  end
end
