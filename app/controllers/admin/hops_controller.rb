class Admin::HopsController < Admin::AdminController

  before_filter :init_hop, only: [:show, :edit_regular, :edit_daily, :tasks]

  def regular
    @tab = 'hops'
    conditions = {daily: false, close: false}
    @hops_grid = initialize_grid(Hop, include: [:producer], per_page: 20, :conditions => conditions,
                                 :order => 'created_at',
                                 :order_direction => 'desc')
  end

  def daily
    @tab = 'daily_hops'
    conditions = {daily: true, close: false}
    @hops_grid = initialize_grid(Hop, include: [:producer], per_page: 20, :conditions => conditions,
                                 :order => 'created_at',
                                 :order_direction => 'desc')
  end

  def current
    @tab = 'current_hops'
    conditions = ["time_start < ? and (time_end > ? or daily = 1) and close = 0", Time.now.utc, Time.now.utc]
    @hops_grid = initialize_grid(Hop, include: [:producer], per_page: 20, :conditions => conditions,
                                 :order => 'created_at',
                                 :order_direction => 'desc')
  end

  def archived
    @tab = 'archived_hops'
    conditions = {close: true}
    @hops_grid = initialize_grid(Hop, include: [:producer], per_page: 20, :conditions => conditions,
                                 :order => 'created_at',
                                 :order_direction => 'desc')
  end

  def show
    @tasks = @hop.hop_tasks
    @hoppers = @hop.hoppers
    @ads = Ad.ads_for_hop @hop
    @prizes = @hop.prizes
  end

  def new_regular
    @tab = 'hops'
    @hop = Hop.new
    @hop.daily = false
  end

  def new_daily
    @tab = 'daily_hops'
    @hop = Hop.new
    @hop.daily = true
  end

  def create
    params[:hop][:producer_id] = current_user.id
    params[:hop][:close] = false
    @hop = Hop.new(params[:hop])
    if @hop.daily
      @hop.time_end = @hop.time_start
    end
    if @hop.save
      redirect_to [:admin, @hop ] , notice: 'Hop was successfully created.'
    else
      if @hop.daily
        render action: 'new_daily'
      else
        render action: 'new_regular'
      end
    end

  end

  def edit_regular

  end

  def edit_daily

  end

  def update
    @hop = Hop.find(params[:id])
    if @hop.daily
      @hop.time_end = @hop.time_start
    end
    if @hop.update_attributes(params[:hop])
      redirect_to [:admin, @hop ], notice: 'Hop was successfully updated.'
    else
      if hop.daily
        render action: 'edit_daily'
      else
        render action: 'edit_regular'
      end
    end
  end

  def destroy
    @hop = Hop.find(params[:id])
    daily_hop = @hop.daily
    @hop.destroy
    if daily_hop
      redirect_to admin_daily_hops_path
    else
      redirect_to admin_regular_hops_path
    end
  end

  def close
    @hop = Hop.find(params[:id])
    if @hop.update_attributes( close: 1)
        flash[:notice] = 'Hop was successfully closed.'
    else
        flash[:error] = 'Error update hop.'
    end
    redirect_to :back
  end

  def sub_layout
    'admin/hops_tabs'
  end

  def print_hop_to_pdf
     output = PdfWritter::TestDocument.new.print_hop_pdf(params[:id])
      respond_to do |format|
        format.pdf {
          send_data output, :filename => "Hop.pdf", :type => "application/pdf", :disposition => "inline"
        }
      end
  end
  def print_hop_list_to_pdf
    (params[:id] == 'current')? @hops = Hop.where(:close => false).all : @hops = Hop.where(:close => true  ).all
    respond_to do |format|
      format.pdf {
        output = PdfWritter::TestDocument.new.hops_to_pdf(@hops)
        send_data output, :filename => "Current_hops.pdf", :type => "application/pdf", :disposition => "inline"
      }
    end
  end

  def print_hop_to_excel
    @hop = Hop.find_by_id(params[:id])
    respond_to do |format|
      format.xls{
        last_col = 0
        clients = Spreadsheet::Workbook.new
        list = clients.create_worksheet :name => ' Hop'
        list.row(1).push "Hop"
        list.row(3).concat ['Id', 'Name', 'Code', 'Time start', 'Time end','Jackpot', 'Special event']
        [@hop].each_with_index { |hop, i|
          list.row(i+4).push hop.id,hop.name,hop.code,hop.time_start.to_s,hop.time_end.to_s,hop.jackpot,hop.event
        }
        list.row(6).concat ['Producer_id', 'Producer contact', 'Producer email', 'Producer phone']
        [@hop.producer].each_with_index { |hop, i|
          list.row(i+7).push hop.id, hop.contact,"#{hop.first_name.to_s + ' ' +hop.last_name.to_s}",hop.email, hop.phone
        }

        list.row(9).push "Winner"
        list.row(11).concat %w{Place Prize}
        @hop.prizes.each_with_index { |winner, i|
          list.row(i+12).push winner.place, winner.cost
          last_col =  last_col + i
        }

        list.row(last_col+13).push 'Items'
       list.row(last_col+15).concat ['Id', 'Text for hop item', 'Sponsor', 'Spponsor_id', 'PTS', ' BNS', 'Price', 'AMT paid']
        z = last_col+16
        @hop.hop_tasks.each_with_index { |item, i|
          list.row(i+z).push item.id, item.text,"#{ item.sponsor.first_name + ' ' + item.sponsor.last_name}", item.sponsor_id, item.pts, item.price, item.amt_paid
          last_col =  last_col + i
        }

        list.row(last_col+17).push 'Ad'
        list.row(last_col+19).concat ['Position', 'Advertizer', 'Logo', 'Price', 'AMT paid']
        z = last_col+20
        @hop.ads.each_with_index { |ad, i|
          list.row(i+z).push ad.ad_type,"#{ ad.advertizer.first_name + ' ' + ad.advertizer.last_name}", ad.picture_file_name, ad.price, ad.amt_paid
          last_col =  last_col + i
        }


        header_format = Spreadsheet::Format.new :color =>:green, :size => 10
        list.row(1).default_format = header_format
        #output to blob object
        blob = StringIO.new("")
        clients.write blob
        #respond with blob object as a file
        send_data blob.string, :type => 'xls', :filename =>'Hop.xls'

      }
    end
  end

  def print_hops_to_excel

    (params[:id] == 'current')? @hops = Hop.where(:close => false).all : @hops = Hop.where(:close => true  ).all


    respond_to do |format|
      format.xls{

          clients = Spreadsheet::Workbook.new
          list = clients.create_worksheet :name => 'Hop List'
         (@hops.first.close)?  (list.row(1).push " Archived hops") : (list.row(1).push " Current hops")

          list.row(3).concat ['Id', 'Name', 'Time start', 'Time end', 'Registered hoppers', 'Items', "Ads"]
          @hops.each_with_index { |hop, i|
            list.row(i+4).push hop.id,hop.name,hop.time_start.to_s,hop.time_end.to_s, hop.hoppers.count, hop.hop_tasks.count, hop.ads.count
          }
          header_format = Spreadsheet::Format.new :color =>:green, :size => 10
          list.row(1).default_format = header_format
          #output to blob object
          blob = StringIO.new("")
          clients.write blob
          #respond with blob object as a file
          send_data blob.string, :type => 'xls', :filename =>'HopList.xls'

       }
    end

  end

  private

  def init_hop
    @hop = Hop.find(params[:id])
    if @hop.daily
      @tab = 'daily_hops'
    else
      @tab = 'hops'
    end
  end



end
