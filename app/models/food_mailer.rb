class FoodMailer < ActionMailer::Base
  def order(recipient, contents)
    from  "kskalski@axit.pl"
    recipients recipient
    subject  "Zamowienie do AXIT"
    body   :recipient => recipient, :contents => contents
  end
  
  def received(recipient, supplier, orderer, material)
    from  "kskalski@axit.pl"
    recipients recipient
    subject  "Do not get overworked, eat something!"
    body  ( :supplier => supplier, :orderer => orderer, :material => material )
  end
end
