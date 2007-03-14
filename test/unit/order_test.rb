require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :suppliers, :materials, :orders, :order_positions

  def test_release
    order = Order.find(1)
    num_deliveries = FoodMailer.deliveries.size
    assert_equal Order::STATE_NEW, order.state
    order.release
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    assert_equal Order::STATE_SENT, order.state
  end
  
  def test_sumworth
    order = Order.find(orders(:sumworth).id)
    assert_equal 4, order.order_positions.length
    assert_in_delta 11.41, order.total_value, 0.0001
  end
  
  def test_material_stat
    order = Order.find(orders(:sumworth).id)
    stat = order.material_stats
    assert_equal 'Foo1', stat[0][0]
    assert_equal 1, stat[0][1]
    assert_equal 'Foo2', stat[1][0]
    assert_equal 2, stat[1][1]
    assert_equal 'Foo3', stat[2][0]
    assert_equal 1, stat[2][1]
  end
  
  def test_received
    order = Order.find(orders(:sumworth).id)
    num_deliveries = FoodMailer.deliveries.size
    assert_equal Order::STATE_NEW, order.state
    order.received
    # only one, global message is sent
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    assert_equal Order::STATE_RECEIVED, order.state
  end
end
