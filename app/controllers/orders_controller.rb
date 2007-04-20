class OrdersController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :send_order, :received ],
         :redirect_to => { :action => :list }

  def list
    @order_pages, @orders = paginate :orders, :order => 'delivery_date DESC', :per_page => 10
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @order.orderer = current_user.email unless !logged_in?
    @all_suppliers = Supplier.find(:all, :order => 'name')
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = 'Order was successfully created.'
      redirect_to :action => 'show', :id => @order
    else
      @all_suppliers = Supplier.find(:all, :order => 'name')
      render :action => 'new'
    end
  end

  def edit
    @order = Order.find(params[:id])
    @all_suppliers = Supplier.find(:all, :order => 'name')
  end

  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      flash[:notice] = 'Order was successfully updated.'
      redirect_to :action => 'show', :id => @order
    else
      @all_suppliers = Supplier.find(:all, :order => 'name')
      render :action => 'edit'
    end
  end

  def destroy
    Order.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def send_order
    @order = Order.find(params[:id])
    @order.release()
    flash[:notice] = 'Order sent!'
    redirect_to :action => 'show', :id => @order
  end
  
  def received
    @order = Order.find(params[:id])
    @order.received()
    redirect_to :action => 'show', :id => @order
  end
end
