class User < ActiveRecord::Base
  has_many :hops,  foreign_key: "producer_id"
  has_many :hop_tasks,  foreign_key: "sponsor_id"
  has_many :user_hop_tasks
  has_many :users_roles
  has_and_belongs_to_many :roles
  has_many :services, :dependent => :destroy


  before_create :create_role
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable

  attr_accessible :email, :password, :last_name, :first_name, 
         :user_name, :password_confirmation, :remember_me, :zip, :avatar

  has_attached_file :avatar, :styles => { :original => "400x400>", :small => "50x50" },
                    :url  => "/images/avatars/users/:id/:style/USER_AVATAR.:extension",
                    :default_url => "/assets/noavatar.gif",
                    :path => ":rails_root/public/images/avatars/users/:id/:style/USER_AVATAR.:extension"


 validates :email, :password, :zip, :presence => true
 validates :zip, numericality: {only_integer: true}

  def role?(role)
    !!self.roles.find_by_name(role.to_s.camelize)
  end

  private

  def create_role
    self.roles << Role.find_by_name(:user)
  end

end
