class Order < ActiveRecord::Base
  validates_presence_of :delivery_date, :supplier_id, :orderer
  validates_format_of :orderer, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :supplier_id, :scope => 'delivery_date'
  
  has_many :order_positions
  belongs_to :supplier
  
  def release
    ord = OrderPosition.count(:conditions => "order_id = #{id}", :group => :material_id)
    return FoodMailer::deliver_order(supplier.email, ord)
  end
  
  def received
    for pos in order_positions
      FoodMailer::deliver_received(pos.receiver_email, supplier.name, orderer, pos.material.name)
    end
  end
end
