class Admin::HopsController < Admin::AdminController
  # GET /hops
  # GET /hops.json
  before_filter :authenticate_user!
  before_filter :parse_datetime_select, :only => [:create, :update]

  def index
   if params[:daily_hop]
     @daily_hop=1
     @hops= Hop.daily
   else
     @hops = Hop.regular 
   end



    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @hops }
    end
  end

  # GET /hops/1
  # GET /hops/1.json
  def show

    @hop = Hop.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @hop }
    end
  end

  # GET /hops/new
  # GET /hops/new.json
  def new
    @hop = Hop.new
    @hop.daily_hop = true if params[:daily_hop]

    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @hop }
    end
  end

  # GET /hops/1/edit
  def edit
    @hop = Hop.find(params[:id])
    @hop.time_end=0
    @hop.time_start=0
  end

  # POST /hops
  # POST /hops.json
  def create
    params[:hop][:producer_id]=current_user.id
    @hop = Hop.new(params[:hop])

    respond_to do |format|
      if @hop.save
        format.html { redirect_to [:admin, @hop ] , notice: 'Hop was successfully created.' }
        format.json { render json: [:admin, @hop ], status: :created, location: @hop }
      else
        format.html { render action: "new" }
        format.json { render json: [:admin, @hop ].errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hops/1
  # PUT /hops/1.json
  def update

    @hop = Hop.find(params[:id])

    respond_to do |format|
      if @hop.update_attributes(params[:hop])
        format.html { redirect_to [:admin, @hop ], notice: 'Hop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hops/1
  # DELETE /hops/1.json
  def destroy
    @hop = Hop.find(params[:id])
    daily_hop=@hop.daily_hop
    @hop.destroy

    respond_to do |format|
      format.html { redirect_to admin_hops_path(:daily_hop => daily_hop) }
      format.json { head :no_content }
    end
  end

  def close
    @hop = Hop.find(params[:id])

    respond_to do |format|
      if @hop.update_attributes(:close=>1)
        format.html { redirect_to admin_hops_path({:daily_hop => @hop.daily_hop}) , notice: 'Hop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hop.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def parse_datetime_select
    {:date_start => :time_start, :date_end => :time_end}.each_pair do |k, v|
      p = params[k]
      params[:hop][v] = DateTime.new(Date.today.year,
                                     p["#{v}(2i)"].to_i,
                                     p["#{v}(3i)"].to_i,
                                     p["#{v}(4i)"].to_i,
                                     p["#{v}(5i)"].to_i)
    end
  end
end
