require 'digest/sha1'
class User < ActiveRecord::Base
  has_and_belongs_to_many :suppliers	
  cattr_accessor :current_user

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def get_finance_analysis
    if email.nil?
      []
    else
      ActiveRecord::Base.connection.select_all(
        "SELECT person, sum(money) AS total FROM ( \n"+
        "    SELECT orderer AS person, -debt_for_orderer as money \n"+
        "      FROM order_positions, orders \n"+
        "      WHERE debt_for_orderer <> 0 AND receiver_email = '#{email}' AND orders.id = order_positions.order_id \n"+
        "  UNION ALL \n"+
        "    SELECT receiver_email AS person, debt_for_orderer as money \n"+
        "      FROM order_positions, orders \n"+
        "      WHERE debt_for_orderer <> 0 AND orderer = '#{email}' AND orders.id = order_positions.order_id \n"+
        ") c\n"+
        "GROUP BY person HAVING total <> 0")
    end
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
