class FoodMailer < ActionMailer::Base
  def order(recipient, orderer, contents)
    from  smtp_settings[:user_name]
    bcc orderer
    recipients recipient
    subject  "Zamowienie do AXIT"
    body   :recipient => recipient, :contents => contents
  end
  
  def received(recipient, supplier, orderer)
    from  smtp_settings[:user_name]
    recipients recipient
    subject  "Do not get overworked, eat something!"
    body( :supplier => supplier, :orderer => orderer )
  end
  
  def notification(recipient, order)
    from  smtp_settings[:user_name]
    recipients recipient
    subject  "Maybe eat something from " + order.supplier.name + " ?"
    body( :order => order)
  end  
end
