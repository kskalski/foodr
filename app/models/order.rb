class Order < ActiveRecord::Base
  validates_presence_of :delivery_date, :supplier_id, :orderer
  validates_format_of :orderer, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :supplier_id, :scope => 'delivery_date'
  
  has_many :order_positions, :order => 'material_id', :dependent => :delete_all
  belongs_to :supplier
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  
  STATE_NEW       = 1
  STATE_SENT      = 2
  STATE_CONFIRMED = 3
  STATE_RECEIVED  = 4
  
  before_create { |me| me.state = STATE_NEW }
  
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
    return if state > STATE_SENT || order_positions.empty?
    
    unless supplier.email.nil? || supplier.email.length == 0 
      mail = FoodMailer::create_order(supplier.email, orderer, material_stats)
      mail.reply_to = orderer
      msg = FoodMailer::deliver(mail)
    end
    update_attribute(:state, STATE_SENT)
    return msg
  end
  
  def received
    return if order_positions.empty?
    recip = order_positions.map { |pos| pos.receiver_email }
    FoodMailer::deliver_received(recip, supplier.name, orderer)
    update_attribute(:state, STATE_RECEIVED)
  end
  
  def notification
    return if supplier.users.empty?
    recip = supplier.users.map { |user| user.email }
    FoodMailer::deliver_notification(recip, self)
  end  
end
