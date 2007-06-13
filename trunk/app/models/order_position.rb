class OrderPosition < ActiveRecord::Base
  validates_presence_of :receiver_email, :material_id, :debt_for_orderer
  validates_format_of :receiver_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_numericality_of :debt_for_orderer

  belongs_to :order
  belongs_to :material
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"  
  
  protected
    def validate_on_create
      if order.state > Order::STATE_NEW
        errors.add(:order_id, 'has been already sent')
      end
    end
end
