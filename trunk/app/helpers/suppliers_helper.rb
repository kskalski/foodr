module SuppliersHelper
  def watched?(supplier)
    for user in supplier.users
       return true if user.id == current_user.id
    end
    return false
  end 
end
