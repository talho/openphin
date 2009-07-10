class PhinPeopleController < ApplicationController
  #auto_complete_for :phin_person, :first_name
  #auto_complete_for :phin_person, :display_name
  #auto_complete_for :phin_person, :last_name

  # GET /phin_people
  # GET /phin_people.xml
  def index
    @phin_people = PhinPerson.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phin_people }
    end
  end

  # GET /phin_people/1
  # GET /phin_people/1.xml
  def show
    @phin_person = PhinPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phin_person }
    end
  end

  # GET /phin_people/new
  # GET /phin_people/new.xml
  def new
    @phin_person = PhinPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phin_person }
    end
  end

  # GET /phin_people/1/edit
  def edit
    @phin_person = PhinPerson.find(params[:id])
  end

  # POST /phin_people
  # POST /phin_people.xml
  def create
    externalUID=params[:phin_person][:email].to_phin_oid unless params[:phin_person][:email].nil?  
    @phin_person = PhinPerson.new(params[:phin_person])
    @phin_person.phin_oid=externalUID
    if @phin_person.save
      roles=params[:phin_roles]
      roles.each_value do |r|
      pr = PhinRole.find(r["role_id"])
      pj = r['jurisdiction_id'].empty? ? PhinJurisdiction.find(r["jurisdiction_id"]) : nil 
      if pr.approval_required?
        flash[:notice] = "Requested role requires approval.  Your request has been logged and will be looked at by an administrator.<br/>"
        rr=RoleRequest.new
        rr.role=pr
        rr.phin_jurisdiction = pj if pj
        rr.requester=@phin_person
        rr.save
      else
        rm=@phin_person.role_memberships.create(:phin_role => pr)
        rm.phin_jurisdiction = pj if pj
        @phin_person.save
      end


      end
    else
      error_flag=true
    end
    respond_to do |format|
      if @phin_person.errors.length > 0
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      else
        flash[:notice] = 'PhinPerson was successfully created.'
        #TODO Fix redirect_to to accept ActiveLdap object
        format.html { redirect_to(@phin_person) }
        format.xml  { render :xml => @phin_person, :status => :created, :location => @phin_person }  
      end
    end
  end

  # PUT /phin_people/1
  # PUT /phin_people/1.xml
  def update
    @phin_person = PhinPerson.find(params[:id])
    if @phin_person.update_attributes(params[:phin_person])
      roles=params[:phin_roles]
      roles.each_value do |r|

        if r["_delete"]
          RoleMembership.destroy(r[:id]) if r[:id]
        elsif r['id'].nil?
          pr = PhinRole.find(r["role_id"])
          pj =  r['jurisdiction_id'].nil? ? PhinJurisdiction.find(r["jurisdiction_id"]) : nil 
          if pr.approval_required?
            flash[:notice] = "Requested role requires approval.  Your request has been logged and will be looked at by an administrator.<br/>"
            rr=RoleRequest.new
            rr.role=pr
            rr.requester=@phin_person
            rr.save
          else
            rm=@phin_person.role_memberships.create(:phin_role => pr)
            rm.phin_jurisdiction = pj if pj
            @phin_person.save
          end
        end
      end
    else
      error_flag=true
    end
    respond_to do |format|
      if @phin_person.errors.length > 0
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      else
        flash[:notice]= 'PhinPerson was successfully updated.'
        #TODO Fix redirect_to to accept ActiveLdap object
        format.html { redirect_to(@phin_person) }
        format.xml  { render :xml => @phin_person, :status => :updated, :location => @phin_person }
      end
    end
  end

  # DELETE /phin_people/1
  # DELETE /phin_people/1.xml
  def destroy
    @phin_person = PhinPerson.find(params[:id])
    @phin_person.destroy

    respond_to do |format|
      format.html { redirect_to(phin_people_url) }
      format.xml  { head :ok }
    end
  end
end
