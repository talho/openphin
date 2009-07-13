class PhinJurisdictionsController < ApplicationController
  # GET /phin_jurisdictions
  # GET /phin_jurisdictions.xml
  def index
    @phin_jurisdictions = PhinJurisdiction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phin_jurisdictions }
    end
  end

  # GET /phin_jurisdictions/1
  # GET /phin_jurisdictions/1.xml
  def show
    @phin_jurisdiction = PhinJurisdiction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phin_jurisdiction }
    end
  end

  # GET /phin_jurisdictions/new
  # GET /phin_jurisdictions/new.xml
  def new
    @phin_jurisdiction = PhinJurisdiction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phin_jurisdiction }
    end
  end

  # GET /phin_jurisdictions/1/edit
  def edit
    @phin_jurisdiction = PhinJurisdiction.find(params[:id])
  end

  # POST /phin_jurisdictions
  # POST /phin_jurisdictions.xml
  def create
    @phin_jurisdiction = PhinJurisdiction.new(params[:phin_jurisdiction])

    respond_to do |format|
      if @phin_jurisdiction.save
        flash[:notice] = 'PhinJurisdiction was successfully created.'
        format.html { redirect_to(@phin_jurisdiction) }
        format.xml  { render :xml => @phin_jurisdiction, :status => :created, :location => @phin_jurisdiction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_jurisdiction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phin_jurisdictions/1
  # PUT /phin_jurisdictions/1.xml
  def update
    @phin_jurisdiction = PhinJurisdiction.find(params[:id])
    
    respond_to do |format|
      if @phin_jurisdiction.update_attributes(params[:phin_jurisdiction])
        if params[:phin_jurisdiction][:parent_id]
          if params[:phin_jurisdiction][:parent_id].empty?
            @phin_jurisdiction.move_to_root
          else
            @phin_jurisdiction.move_to_child_of(PhinJurisdiction.find(params[:phin_jurisdiction][:parent_id]))
          end
        end
        flash[:notice] = 'PhinJurisdiction was successfully updated.'
        format.html { redirect_to(@phin_jurisdiction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_jurisdiction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phin_jurisdictions/1
  # DELETE /phin_jurisdictions/1.xml
  def destroy
    @phin_jurisdiction = PhinJurisdiction.find(params[:id])
    @phin_jurisdiction.destroy

    respond_to do |format|
      format.html { redirect_to(phin_jurisdictions_url) }
      format.xml  { head :ok }
    end
  end
end
