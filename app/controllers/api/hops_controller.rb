class Api::HopsController < Api::ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :daily, :assign, :get_tasks]
  before_filter :load_hop, only: [:assign, :get_tasks, :get_hop_by_id, :score, :prizes]

  def regular
    params[:page] ||= 1
    params[:per_page] ||= 10
    @hops =  Hop.find_by_sql("SELECT hops.*, IF(hoppers_hops.user_id IS NULL , -1, hoppers_hops.user_id) AS isnull
                              FROM hops
                              LEFT JOIN hoppers_hops on hoppers_hops.hop_id = hops.id
                              LEFT JOIN hop_tasks ON hop_tasks.hop_id = hops.id
                              LEFT JOIN prizes ON prizes.hop_id = hops.id
                              WHERE hops.daily = 0 AND close = 0 AND hop_tasks.id IS NOT NULL AND prizes.id IS NOT NULL
                              GROUP BY hops.id
                              ORDER BY  isnull != #{@current_user.id} , hops.created_at DESC
                              LIMIT #{params[:per_page].to_i} OFFSET #{(params[:page].to_i - 1) * params[:per_page].to_i};")
    if @hops.blank?
      bad_request(['Hops not found.'], 406)
    else
      render 'regular', content_type: 'application/json'
    end
  end

  def daily
    @daily_hop = Hop.find_by_sql(["SELECT hops.*
                                FROM hops
                                LEFT JOIN hop_tasks ON hop_tasks.hop_id = hops.id
                                LEFT JOIN prizes ON prizes.hop_id = hops.id
                                WHERE hops.daily = 1 AND hop_tasks.id IS NOT NULL AND prizes.id IS NOT NULL
                                    AND time_start BETWEEN ? AND ? AND close = 0
                                GROUP BY hops.id
                                LIMIT 1;", DateTime.now.beginning_of_day, DateTime.now.end_of_day]).first
    if @daily_hop == nil
      bad_request(['Daily hop not found.'], 406)
    else
      render 'daily', content_type: 'application/json'
    end
  end

  def get_tasks
    @hop_tasks = @hop.hop_tasks
    render 'get_tasks', content_type: 'application/json'
  end

  def get_hop_by_id
    render 'get_hop_by_id', content_type: 'application/json'
  end

  def score
    respond_to do |format|
      format.json{
        render :json => {success: true,
                         score: @hop.score(@current_user),
                         hoppers_count: @hop.hoppers.count,
                         rank: @hop.rank(@current_user),
                         status: 200
        }
      }
    end
  end

  def yesterdays_winner
    hop = Hop.get_daily_by_date DateTime.now - 1.day
    if hop
      prize = hop.prizes.order("place ASC").first
      if prize && prize.user_id
        respond_to do |format|
          format.json{
            render :json => {success: true,
                             winner_id: prize.user_id,
                             winners_first_name: prize.user.first_name,
                             winners_last_name: prize.user.last_name,
                             winners_avatar: prize.user.avatar.url,
                             score: prize.pts,
                             hoppers_count: hop.hoppers.count,
                             rank: prize.place,
                             hop_id: hop.id,
                             hop_name: hop.name,
                             cost: prize.cost,
                             status: 200
            }
          }
        end
      else
        bad_request(['Missing winner for yesterday\'s hop.'], 406)
      end
    else
      bad_request(['Missing yesterday\'s hop.'], 406)
    end
  end

  def prizes
    @prizes = @hop.prizes
    render 'prizes', content_type: 'application/json'
  end

  private

  def load_hop
    @hop = Hop.where(:id => params[:hop_id]).first   #.includes(:hop_task).where("hop_tasks.id IS NOT NULL")
    bad_request(['Hop not found.'], 406) unless @hop
  end

end
