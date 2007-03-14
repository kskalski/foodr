class Order < ActiveRecord::Base
  validates_presence_of :delivery_date, :supplier_id, :orderer
  validates_format_of :orderer, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :supplier_id, :scope => 'delivery_date'
  
  has_many :order_positions, :order => 'material_id', :dependent => :delete_all
  belongs_to :supplier
  
  def material_stats
    ord = OrderPosition.count(:conditions => "order_id = #{id}", :group => :material_id)
    return ord.map {
      |mat_id,count| [Material.find(mat_id).name, count]
    }
  end

  def total_value
    return OrderPosition.sum('material_price', :conditions => "order_id = #{id}")
  end
    
  def release
    mail = FoodMailer::create_order(supplier.email, orderer, material_stats)
    mail.reply_to = orderer
    return FoodMailer::deliver(mail)
  end
  
  def received
    recip = order_positions.map { |pos| pos.receiver_email }
    FoodMailer::deliver_received(recip, supplier.name, orderer)
  end
end
