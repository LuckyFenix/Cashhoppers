class Hop < ActiveRecord::Base
  has_many :hop_tasks, :dependent => :destroy
  has_many :ads,  :dependent => :destroy
  belongs_to :user

  attr_accessible :contact_email, :close, :event, :daily_hop, :contact_phone, :hop_code, :hop_items, :hop_price, :jackpot, :name, :producer_contact, :producer_id, :time_end, :time_start

  validates_presence_of :time_start, :time_end

  # get only active for default
  default_scope where(:close => false)
  scope :daily, where('daily_hop = 1 AND DATE(time_start) = CURDATE()')
  scope :regular, where(:daily_hop => false)

end
