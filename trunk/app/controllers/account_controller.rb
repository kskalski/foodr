class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # gives summary of debts, where we at some actor
  def finance
    if logged_in? 
      @mydebt_positions = []
      if !current_user.email.nil?
       @mydebt_positions = ActiveRecord::Base.connection.select_all(
        "SELECT person, sum(money) AS total FROM ( \n"+
        "    SELECT orderer AS person, -debt_for_orderer as money \n"+
        "      FROM order_positions, orders \n"+
        "      WHERE debt_for_orderer <> 0 AND receiver_email = '#{current_user.email}' AND orders.id = order_positions.order_id \n"+
        "  UNION \n"+
        "    SELECT receiver_email AS person, debt_for_orderer as money \n"+
        "      FROM order_positions, orders \n"+
        "      WHERE debt_for_orderer <> 0 AND orderer = '#{current_user.email}' AND orders.id = order_positions.order_id \n"+
        ") c\n"+
        "GROUP BY person HAVING total <> 0")
      end
      session[:debt] = @mydebt_positions
    else 
      if User.count > 0
        redirect_to(:action => 'login')
      else
        redirect_to(:action => 'signup')
      end 
    end
  end

  def zero_debt
    other_user = params[:against].to_i unless params[:against].nil?
    debt = session[:debt]
    if !other_user.nil? && !debt.nil? && other_user >= 0 && other_user < debt.length
      other_user = debt[other_user]['person']
      poses = OrderPosition.find(:all, :conditions => ['receiver_email IN (?,?)', other_user, current_user])
      poses.each { |p|
        if (p.order.orderer == other_user && p.receiver_email == current_user.email || 
           p.order.orderer == current_user.email && p.receiver_email == other_user)
          p.debt_for_orderer = 0
          p.save
        end
      }
    end
    redirect_to(:action => 'finance')
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:action => 'finance')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:action => 'finance')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => 'orders', :action => 'list')
  end
end
