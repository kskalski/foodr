class OrderPositionsController < ApplicationController
  def index
    list
    render :action => 'show'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :show }

  def remember_order
    if params[:order]
      session[:order] = params[:order] 
    end
    @order = session[:order]
  end         
  
  def show
    remember_order()
    @order_position = OrderPosition.find(params[:id])
  end

  def new
    remember_order()
    @order_position = OrderPosition.new
    @order_position.receiver_email = current_user.email unless !logged_in?
    @all_materials = Material.find(:all, :conditions => "supplier_id = (SELECT supplier_id FROM orders WHERE id = #{@order})", :order => 'name')
  end

  def create
    @order_position = OrderPosition.new(params[:order_position])
    @order = session[:order]
    @order_position.material_price = @order_position.material.price
    if @order_position.save
      flash[:notice] = 'Order position was successfully created.'
      redirect_to :action => 'show', :controller => 'orders', :id => @order
    else
      @all_materials = Material.find(:all, :conditions => "supplier_id = (SELECT supplier_id FROM orders WHERE id = #{@order})", :order => 'name')
      render :action => 'new'
    end
  end

  def edit
    remember_order()
    @order_position = OrderPosition.find(params[:id])
    @all_materials = Material.find(:all, :conditions => "supplier_id = (SELECT supplier_id FROM orders WHERE id = #{@order})", :order => 'name')
  end

  def update
    @order_position = OrderPosition.find(params[:id])
    @order = session[:order]
    if @order_position.update_attributes(params[:order_position])
      @order_position.material_price = @order_position.material.price
      @order_position.save
      flash[:notice] = 'Order position was successfully updated.'
      redirect_to :action => 'show', :controller => 'orders', :id => @order
    else
      @all_materials = Material.find(:all, :conditions => "supplier_id = (SELECT supplier_id FROM orders WHERE id = #{@order})", :order => 'name')
      render :action => 'edit'
    end
  end

  def destroy
    OrderPosition.find(params[:id]).destroy
    redirect_to :action => 'show', :controller => 'orders', :id => params[:order]
  end
end
