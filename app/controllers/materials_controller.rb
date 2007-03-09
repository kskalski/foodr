class MaterialsController < ApplicationController
  def index
    list
    render :action => 'show'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :show }

  def remember_supplier
    if params[:supplier]
      session[:supplier] = params[:supplier] 
    end
    @supplier = session[:supplier]
  end    
         
  def show
    remember_supplier()
    @material = Material.find(params[:id])
  end

  def new
    remember_supplier()
    @material = Material.new
  end

  def create
    @material = Material.new(params[:material])
    @supplier = session[:supplier]
    if @material.save
      flash[:notice] = 'Material was successfully created.'
      redirect_to :action => 'show', :controller => 'suppliers', :id => @supplier
    else
      render :action => 'new'
    end
  end

  def edit
    remember_supplier()
    @material = Material.find(params[:id])
  end

  def update
    @material = Material.find(params[:id])
    @supplier = session[:supplier]
    if @material.update_attributes(params[:material])
      flash[:notice] = 'Material was successfully updated.'
      redirect_to :action => 'show', :controller => 'suppliers', :id => @supplier
    else
      render :action => 'edit'
    end
  end

  def destroy
    Material.find(params[:id]).destroy
    redirect_to :action => 'show', :controller => 'suppliers', :id => params[:supplier]
  end
end
