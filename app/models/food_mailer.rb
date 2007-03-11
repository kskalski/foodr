class FoodMailer < ActionMailer::Base
  def order(recipient, orderer, contents)
    from  smtp_settings[:user_name]
    bcc orderer
    recipients recipient
    subject  "Zamowienie do AXIT"
    body   :recipient => recipient, :contents => contents
  end
  
  def received(recipient, supplier, orderer, material)
    from  smtp_settings[:user_name]
    recipients recipient
    subject  "Do not get overworked, eat something!"
    body( :supplier => supplier, :orderer => orderer, :material => material )
  end
end
