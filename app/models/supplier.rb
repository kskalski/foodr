class Supplier < ActiveRecord::Base
  validates_presence_of :name
  validates_format_of :email, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :name, 
                          :email, :if => '!@email.nil?'
  
  has_many :materials
end
