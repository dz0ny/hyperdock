class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :containers

  def invitation_token
    ""
  end

  def admin?
    self.role == "admin"
  end

end
