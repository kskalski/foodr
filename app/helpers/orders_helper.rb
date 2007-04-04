module OrdersHelper
  def format_state(state)
    case state
      when Order::STATE_NEW then 'New'
      when Order::STATE_SENT then 'Sent'
      when Order::STATE_CONFIRMED then 'Confirmed'
      when Order::STATE_RECEIVED then 'Received'      
      else state
    end
  end
end
