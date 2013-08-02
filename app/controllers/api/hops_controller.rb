class Api::HopsController < Api::ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :daily, :assign, :get_tasks]
  before_filter :load_hop, only: [:assign, :get_tasks, :get_hop_by_id, :score]

  def regular
    params[:page] ||= 1
    params[:per_page] ||= 10
    @hops =  Hop.find_by_sql("SELECT hops.*, IF(hoppers_hops.user_id IS NULL , -1, hoppers_hops.user_id) AS isnull
                              FROM hops LEFT JOIN hoppers_hops on hoppers_hops.hop_id = hops.id WHERE hops.daily = 0 ORDER BY  isnull != #{@current_user.id} , hops.created_at DESC
                              LIMIT #{params[:per_page].to_i} OFFSET #{(params[:page].to_i - 1) * params[:per_page].to_i};")
    bad_request(['Hops not found.'], 406) if @hops.blank?
    respond_to do |f|
      f.json{}
    end
  end

  def daily
    @hops = Hop.paginate(:page => params[:page],
                         per_page: params[:per_page],
                         conditions: ["time_start BETWEEN ? AND ? AND daily = 1 AND close = 0", DateTime.now.beginning_of_day, DateTime.now.end_of_day])
    if @hops.blank?
      bad_request(['Hops not found.'], 406) if @hops.blank?
    end
    respond_to do |f|
      f.json{}
    end
  end

  def get_tasks
    @hop_tasks = @hop.hop_tasks
    respond_to do |f|
      f.json{}
    end
  end

  def get_hop_by_id
    respond_to do |format|
      format.json{}
    end
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
      winner = hop.winner 1
      if !winner
        bad_request(['Missing winner for yesterday\'s hop.'], 406)
      else
        respond_to do |format|
          format.json{
            render :json => {success: true,
                             winner_id: winner['user_id'],
                             score: winner['pts'],
                             hoppers_count: hop.hoppers.count,
                             rank: 1,
                             hop_id: hop.id,
                             status: 200
            }
          }
        end
      end
    else
      bad_request(['Missing yesterday\'s hop.'], 406)
    end
  end

  private

  def load_hop
    @hop = Hop.where(:id => params[:hop_id]).first
    bad_request(['Hop not found.'], 406) unless @hop
  end

end
