class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :containers

  def admin?
    self.role == "admin"
  end

  def at_container_limit?
    self.containers.count >= self.container_limit
  end

  def get_auth_token!
    token = SecureRandom.urlsafe_base64(32)
    self.update_column(:auth_token, token)
    token
  end
end
