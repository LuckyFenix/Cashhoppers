class Admin::ApplicationsController < Admin::AdminController
  load_and_authorize_resource
  # GET /admin/applications
  # GET /admin/applications.json
  def index
    @applications = Application.all

    respond_to do |format|
      format.html # index.html.haml
      format.json { render json: @applications }
    end
  end

  # GET /admin/applications/1
  # GET /admin/applications/1.json
  def show
    @application = Application.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application }
    end
  end

  # GET /admin/applications/new
  # GET /admin/applications/new.json
  def new
    @application = Application.new
    range = [*'0'..'9', *'a'..'z', *'A'..'Z']
    @application.api_key = Array.new(30){range.sample}.join

    respond_to do |format|
      format.html # new.html.haml
      format.json { render json: @application }
    end
  end

  # GET /admin/applications/1/edit
  def edit
    @application = Application.find(params[:id])
  end

  # POST /admin/applications
  # POST /admin/applications.json
  def create
    @application = Application.new(params[:application])

    respond_to do |format|
      if @application.save
        format.html {
          flash[:success] = 'Application ' + @application.name + ' was successfully created.'
          redirect_to [:admin, @application]
        }
        format.json { render json: @application, status: :created, location: @application }
      else
        format.html {
          flash[:error] = 'Failed to update application.'
          render action: "new"
        }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/applications/1
  # PUT /admin/applications/1.json
  def update
    @application = Application.find(params[:id])

    respond_to do |format|
      if @application.update_attributes(params[:application])
        format.html {
          flash[:success] = 'Application was successfully updated.'
          redirect_to [:admin, @application]
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:error] = 'Failed to update application.'
          render action: "edit"
        }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/applications/1
  # DELETE /admin/applications/1.json
  def destroy
    @application = Application.find(params[:id])
    @application.destroy

    respond_to do |format|
      format.html {
        flash[:notice] = 'Application was successfully destroyed.'
        redirect_to admin_applications_url
      }
      format.json { head :no_content }
    end
  end
end
