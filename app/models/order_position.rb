class OrderPosition < ActiveRecord::Base
  validates_presence_of :receiver_email, :material_id, :debt_for_orderer
  validates_format_of :receiver_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_numericality_of :debt_for_orderer

  belongs_to :order
  belongs_to :material
end
