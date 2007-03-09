class CreateSuppliers < ActiveRecord::Migration
  def self.up
    create_table :suppliers do |t|
      t.column :name, :string
      t.column :email, :string
      t.column :phones, :string
    end
    
    create_table :materials do |t|
      t.column :supplier_id, :integer    
      t.column :name, :string
      t.column :price, :float
    end
    
    rename_column :orders, :supplier, :supplier_id
    change_column :orders, :supplier_id, :integer
    rename_column :order_positions, :material, :material_id
    change_column :order_positions, :material_id, :integer
    add_column :order_positions, :material_price, :float
  end

  def self.down
    add_column :order_positions, :material_price, :float
    change_column :order_positions, :material_id, :integer
    rename_column :order_positions, :material, :material_id
    change_column :orders, :supplier_id, :integer
    rename_column :orders, :supplier, :supplier_id

    drop_table :dishes
    drop_table :suppliers
  end
end
