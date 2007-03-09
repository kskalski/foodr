class Material < ActiveRecord::Base
  validates_presence_of :name, :price, :supplier_id
  validates_uniqueness_of :name, :scope => 'supplier_id'
  
  belongs_to :supplier
end
