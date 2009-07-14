class JurisdictionsController < ApplicationController
  # GET /jurisdictions
  # GET /jurisdictions.xml
  def index
    @jurisdictions = Jurisdiction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jurisdictions }
    end
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
    @jurisdiction = Jurisdiction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @jurisdiction }
    end
  end

  # GET /jurisdictions/1/edit
  def edit
    @jurisdiction = Jurisdiction.find(params[:id])
  end

  # POST /jurisdictions
  # POST /jurisdictions.xml
  def create
    @jurisdiction = Jurisdiction.new(params[:jurisdiction])

    respond_to do |format|
      if @jurisdiction.save
        flash[:notice] = 'PhinJurisdiction was successfully created.'
        format.html { redirect_to(@jurisdiction) }
        format.xml  { render :xml => @jurisdiction, :status => :created, :location => @jurisdiction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @jurisdiction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /jurisdictions/1
  # PUT /jurisdictions/1.xml
  def update
    @jurisdiction = Jurisdiction.find(params[:id])
    
    respond_to do |format|
      if @jurisdiction.update_attributes(params[:jurisdiction])
        if params[:jurisdiction] && params[:jurisdiction][:parent_id]
          if params[:jurisdiction][:parent_id].empty?
            @jurisdiction.move_to_root
          else
            @jurisdiction.move_to_child_of(Jurisdiction.find(params[:jurisdiction][:parent_id]))
          end
        end
        flash[:notice] = 'PhinJurisdiction was successfully updated.'
        format.html { redirect_to(@jurisdiction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @jurisdiction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jurisdictions/1
  # DELETE /jurisdictions/1.xml
  def destroy
    @jurisdiction = Jurisdiction.find(params[:id])
    @jurisdiction.destroy

    respond_to do |format|
      format.html { redirect_to(jurisdictions_url) }
      format.xml  { head :ok }
    end
  end
end
