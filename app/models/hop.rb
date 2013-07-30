class Hop < ActiveRecord::Base
  has_and_belongs_to_many :hoppers, :join_table =>"hoppers_hops" , :class_name=>"User"

  has_many :hop_tasks, :dependent => :destroy
  has_many :ads,  :dependent => :destroy
  belongs_to :producer, :class_name => 'User'
  has_attached_file :logo,
                    :url  => "/images/hop_logos/hops/:id/HOP_LOGO.:extension",
                    :default_url => "/assets/no_hop_logo.png",
                    :path => ":rails_root/public/images/hop_logos/hops/:id/HOP_LOGO.:extension"
  has_many :prizes

  attr_accessible :close, :event, :daily, :code, :price, :jackpot, :name, :producer_id, :time_end, :time_start, :logo

  validates_presence_of :time_start, :name
  validates_presence_of :time_end, :jackpot,  :producer_id, unless: :daily?
  validates :jackpot, numericality: { only_integer: true }, unless: :daily?
  validates :price, numericality: true, unless: :daily?

  def self.get_daily_by_date date
    Hop.where("time_start BETWEEN ? AND ? AND daily = 1 AND close = 0", date.beginning_of_day.strftime("%d/%m/%Y %H:%M:%S"), date.end_of_day.strftime("%d/%m/%Y %H:%M:%S")).first
  end

  def assign user
    unless hoppers.include? user
      hoppers << user
      ActiveRecord::Base.connection().execute("UPDATE hoppers_hops SET pts = 0 WHERE user_id = #{user.id} AND hop_id = #{id}")
    end
  end

  def score user
    hoppers_hops = ActiveRecord::Base.connection.select_all("SELECT pts FROM hoppers_hops WHERE user_id = #{user.id} AND hop_id = #{id} LIMIT 1")
    if hoppers_hops.length == 0
      0
    else
      hoppers_hops[0]['pts']
    end
  end

  def increase_score user, pts
    current_pts = self.score user
    ActiveRecord::Base.connection().execute("UPDATE hoppers_hops SET pts = #{current_pts + pts} WHERE user_id = #{user.id} AND hop_id = #{id}")
  end

  def rank user
    user_position = ActiveRecord::Base.connection.select_all("
      SELECT rank FROM
      (
        SELECT hoppers_hops.user_id, @rownum := @rownum + 1 AS rank
        FROM hoppers_hops, (SELECT @rownum := 0) r
        WHERE hop_id = #{id}
        ORDER BY hoppers_hops.pts DESC
      ) selection
      WHERE user_id = #{user.id};
    ")
    if user_position.length > 0
      user_position = user_position[0]['rank']
    else
      user_position = 0
    end
  end

  def winner place
    winner = ActiveRecord::Base.connection.select_all("SELECT hoppers_hops.* FROM hoppers_hops WHERE hop_id = #{id} ORDER BY pts DESC LIMIT 1 OFFSET #{ place - 1 };");
    if winner.blank?
      nil
    else
      winner[0]
    end
  end

  def self.find_old
    find(:all, :conditions => ["((time_end < ? AND daily = 0) OR (time_end < ? AND daily = 1)) AND close = 0", DateTime.now, DateTime.now.beginning_of_day ])
  end

  def self.close_old_hops
    @old_hops = Hop.find_old
    @old_hops.each do |hop|
      #mark hop as closed
      hop.update_attribute :close, true
      hop.prizes.each do |prize|
        winner = hop.winner prize.place
        #set prize user
        prize.update_attribute :user_id, winner['id']
        #send message to winner
        message = Message.new(text: "You have won #{prize.place} prize in a hop #{ hop.name }", receiver_id: winner['id'])
        message.save
        #notificate hoppers about end of hop
        hop.hoppers.each do |hopper|
          Notification.create(user_id: hopper.id, event_type: 'End of hop', prize_id: prize.id)
        end
      end
    end
  end

end