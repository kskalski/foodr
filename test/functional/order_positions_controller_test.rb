require File.dirname(__FILE__) + '/../test_helper'
require 'order_positions_controller'

# Re-raise errors caught by the controller.
class OrderPositionsController; def rescue_action(e) raise e end; end

class OrderPositionsControllerTest < Test::Unit::TestCase
  fixtures :suppliers, :materials, :orders, :order_positions

  def setup
    @controller = OrderPositionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:order_position)
    assert assigns(:order_position).valid?
  end

  def test_new
    get :new, :order => 1

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:order_position)
  end

  def test_create
    num_order_positions = OrderPosition.count

    post :create, :order_position => { :order_id => '1', :receiver_email => 'foo@bar.pl', :debt_for_orderer => '0', :material_id => '1' }

    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'orders'

    assert_equal num_order_positions + 1, OrderPosition.count
  end

  def test_edit
    get :edit, :id => 1, :order => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:order_position)
    assert assigns(:order_position).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'orders'
  end

  def test_destroy
    assert_not_nil OrderPosition.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'orders'

    assert_raise(ActiveRecord::RecordNotFound) {
      OrderPosition.find(1)
    }
  end
end
