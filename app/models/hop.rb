class Hop < ActiveRecord::Base
  has_many :hop_tasks, :dependent => :destroy
  has_many :ads,  :dependent => :destroy
  belongs_to :user

  attr_accessible :contact_email, :close, :event, :daily_hop, :contact_phone, :hop_code, :hop_items, :hop_price, :jackpot, :name, :producer_contact, :producer_id, :time_end, :time_start

  validates_presence_of :time_start, :time_end, :name

  # get only active for default
  default_scope where(:close => false)
  scope :daily, where('daily_hop = 1 AND DATE(time_start) = CURDATE()')
  scope :daily_all, where(:daily_hop => true )
  scope :regular, where(:daily_hop => false)

  validates_presence_of :contact_email,  :hop_code, :jackpot,  :producer_id, if: :daily_hop?
  validates :hop_items, :jackpot, numericality: { only_integer: true }, if: :daily_hop?
  validates :hop_price, numericality: true, if: :daily_hop?
  validates :contact_phone, :producer_contact, length: { minimum: 5}, if: :daily_hop?

  def daily_hop?
    daily_hop.class == FalseClass
  end

end

