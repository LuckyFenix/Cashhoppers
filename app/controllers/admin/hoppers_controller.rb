class Admin::HoppersController < Admin::AdminController
  include ::PdfWritter
  authorize_resource

  def find_hopper
    @tab = 'find_hoppers'

    @user = User.find_by_id(session[:last_hopper])  if session[:last_hopper]
  end

  def hopper_list
   @tab = 'generate_hoppers_list'
   @id_array = session[:last_hoppers]  if session[:last_hoppers]
   @users = session[:last_hoppers].map{|id| User.find_by_id(id)}  if session[:last_hoppers]

   if  params[:id]
     output = PdfWritter::TestDocument.new.to_pdf_hopper_list(params[:id])
     respond_to do |format|
       format.pdf {
         send_data output, :filename => "HopperList.pdf", :type => "application/pdf", :disposition => "inline"
       }
     end
   end
  end

  def sub_layout
    'admin/hoppers_tabs'
  end

  def search_by_name
    conditions = ["user_name LIKE ? OR user_name LIKE ?", "%#{params[:qwery]}%", "%#{params[:qwery]}%"]
    @users = User.paginate(page: params[:page], per_page:9, conditions:  conditions)
    render :partial=> 'users_list'
  end

  def search_user
    params[:page] ||= 1
    params[:per_page] ||= 7
    @users = User.paginate page: params[:page], per_page: params[:per_page]
    render :partial=> 'users_list'
  end

  def search_hop_list
    params[:page] ||= 1
    params[:per_page] ||= 7
    @hops = Hop.paginate page: params[:page], per_page: params[:per_page]
     render partial: 'users_hop_list'
  end

  def search_zip_list
    params[:page] ||= 1
    params[:per_page] ||= 7
    @zips = User.group(:zip).select(:zip).paginate page: params[:page], per_page: params[:per_page]
     render partial: 'users_zip_list'
  end

  def select_user
    @user = User.find_by_id(params[:id])
    session[:last_hopper]= params[:id]
    render :partial => 'hopper_info'

  end

  def select_hop
    @users = Hop.find_by_id(params[:id]).hoppers.all

    @id_array = @users.map{|user| user.id }
    #session[:last_hoppers]= @id_array
    render :partial => 'generate_hop_list'
  end

  def select_zip
    @users = User.where(:zip => params[:zip]).all

    @id_array = @users.map{|user| user.id }

    session[:last_hoppers]= @id_array
    render :partial => 'generate_hop_list'
    #render :text => @id_array
  end


  def search_by_zip
    conditions = ["zip LIKE ? OR zip LIKE ?", "%#{params[:qwery]}%", "%#{params[:qwery]}%"]
    @zips = User.group(:zip).select(:zip)
    @zips = @zips.paginate(:page => 1, :per_page => 9,  conditions:  conditions )
    render :partial=> 'users_zip_list'
  end

  def search_by_hop
    conditions = ["name LIKE ? OR name LIKE ?", "%#{params[:qwery]}%", "%#{params[:qwery]}%"]
    @hops = Hop.paginate(page: params[:page], per_page:9, conditions:  conditions)
    render :partial=> 'users_hop_list'
  end

  def hopper_to_pdf
    if  params[:id]
      output = PdfWritter::TestDocument.new.to_pdf_hopper(params[:id])
      respond_to do |format|
        format.pdf {
          send_data output, :filename => "Hopper.pdf", :type => "application/pdf", :disposition => "inline"
        }
      end
    end
  end

  def export_to_excel
    @gamers = []
    for i in params[:id]
      @gamers  << User.find_by_id(i)
    end

    respond_to do |format|
      format.xls{

          clients = Spreadsheet::Workbook.new
          list = clients.create_worksheet :name => 'List of cliets'
          list.row(1).push "Hoppers list"
          list.row(3).concat %w{Id User_name First_name Last_name Zip Email}
          @gamers.each_with_index { |client, i|
            list.row(i+4).push client.id,client.user_name,client.first_name,client.last_name,client.zip,client.email
          }
          header_format = Spreadsheet::Format.new :color =>:green, :size => 10
          list.row(1).default_format = header_format
          #output to blob object
          blob = StringIO.new("")
          clients.write blob
          #respond with blob object as a file
          send_data blob.string, :type => 'xls', :filename =>'Hoppers_list.xls'

      }
    end
  end

end
