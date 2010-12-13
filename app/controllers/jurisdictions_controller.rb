class JurisdictionsController < ApplicationController
  before_filter :non_public_role_required
  before_filter :admin_required, :except => [:mapping, :index, :user_alerter]
  before_filter :change_include_root, :only => [:index, :mapping, :user_alerter, :user_alerting]
  after_filter :change_include_root_back, :only => [:index, :mapping, :user_alerter, :user_alerting]
  app_toolbar "han"


  def mapping
    jurisdictions = fetch_jurisdictions(params[:request])
    respond_to do |format|
      # this header is a must for CORS
      headers["Access-Control-Allow-Origin"] = "*"
      json = "{\"jurisdictions\": #{jurisdictions.to_json(params[:request])},\"latest_in_secs\": #{Jurisdiction.latest_in_secs} }"
      format.json {render :json => json }
    end
  end

  # GET /jurisdictions
  # GET /jurisdictions.xml
  def index
    respond_to do |format|
      format.html { render :html => (@jurisdictions = Jurisdiction.all)}
      format.xml  { render :xml =>  (@jurisdictions = Jurisdiction.all)}
      format.json do
        # this header is a must for CORS
        headers["Access-Control-Allow-Origin"] = "*"
        if params[:admin_mode] == "1"
          @jurisdictions = current_user.jurisdictions.admin.find(:all,:select=>'jurisdictions.id,name')
        else
          @jurisdictions = Jurisdiction.find(:all,:select=>'id,name')
        end
        render :json => {"jurisdictions"=>@jurisdictions,"expires_on"=>1.day.since.to_i*1000}
      end
    end
  end

  def user_alerting
    jurisdictions = current_user.alerting_jurisdictions
    render :json => jurisdictions.to_json(:only => ['id', 'name'])
  end

  def user_alerter
    jurisdictions = current_user.alerter_jurisdictions
    render :json => jurisdictions.to_json(:only => ['id', 'name'])
  end

  # GET /jurisdictions/1
  # GET /jurisdictions/1.xml
  def show
    @jurisdiction = Jurisdiction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @jurisdiction }
    end
  end

  # GET /jurisdictions/new
  # GET /jurisdictions/new.xml
  def new
    logger.warn "User id #{current_user.id} attempted to create a new jurisdiction"
    #@jurisdiction = Jurisdiction.new

    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.xml  { render :xml => @jurisdiction }
    #end
  end

  # GET /jurisdictions/1/edit
  def edit
    logger.warn "User id #{current_user.id} attempted to edit jurisdiction with id #{params[:id]}"
    #@jurisdiction = Jurisdiction.find(params[:id])
  end

  # POST /jurisdictions
  # POST /jurisdictions.xml
  def create
    logger.warn "User id #{current_user.id} attempted to create a new jurisdiction"
        #@jurisdiction = Jurisdiction.new(params[:jurisdiction])

    #respond_to do |format|
    #  if @jurisdiction.save
    #    flash[:notice] = 'PhinJurisdiction was successfully created.'
    #    format.html { redirect_to(@jurisdiction) }
    #    format.xml  { render :xml => @jurisdiction, :status => :created, :location => @jurisdiction }
    #  else
    #    format.html { render :action => "new" }
    #    format.xml  { render :xml => @jurisdiction.errors, :status => :unprocessable_entity }
    #  end
    #end
  end

  # PUT /jurisdictions/1
  # PUT /jurisdictions/1.xml
  def update
    logger.warn "User id #{current_user.id} attempted to update jurisdiction with id #{params[:id]}"
    #@jurisdiction = Jurisdiction.find(params[:id])
    
    #respond_to do |format|
    #  if @jurisdiction.update_attributes(params[:jurisdiction])
    #    if params[:jurisdiction] && params[:jurisdiction][:parent_id]
    #      if params[:jurisdiction][:parent_id].empty?
    #       @jurisdiction.move_to_root
    #      else
    #        @jurisdiction.move_to_child_of(Jurisdiction.find(params[:jurisdiction][:parent_id]))
    #      end
    #    end
    #    flash[:notice] = 'PhinJurisdiction was successfully updated.'
    #    format.html { redirect_to(@jurisdiction) }
    #    format.xml  { head :ok }
    #  else
    #    format.html { render :action => "edit" }
    #    format.xml  { render :xml => @jurisdiction.errors, :status => :unprocessable_entity }
    #  end
    #end
  end

  # DELETE /jurisdictions/1
  # DELETE /jurisdictions/1.xml
  def destroy
    logger.warn "User id #{current_user.id} attempted to destroy jurisdiction with id #{params[:id]}"
    #@jurisdiction = Jurisdiction.find(params[:id])
    #@jurisdiction.destroy

    #respond_to do |format|
    #  format.html { redirect_to(jurisdictions_url) }
    #  format.xml  { head :ok }
    #end
  end

protected

    def fetch_jurisdictions(options={})
      return [] if options.empty?
      if ( options[:age] && (Jurisdiction.recent(1).first.updated_at.utc.to_i == options[:age]) )
        return []
      end
      method = options[:method]
      return [] unless (Jurisdiction.public_methods-Jurisdiction.instance_methods).include? method.to_s
      Jurisdiction.send(method ? method : :all)
    end
    
end
