class PhinPeopleController < ApplicationController
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
    @phin_person = PhinPerson.find_with_encoded_id(params[:id])

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
    @phin_person = PhinPerson.find_with_encoded_id(params[:id])
  end

  # POST /phin_people
  # POST /phin_people.xml
  def create
    debugger
    cn= "#{params[:phin_person][:givennname]} #{params[:phin_person][:sn]}"
    externalUID=params[:phin_person][:mail].to_phin_oid
    @phin_person = PhinPerson.new(params[:phin_person])
    @phin_person.cn=cn
    @phin_person.externalUID=externalUID
    @phin_person.dn="externalUID=#{externalUID}"
    if @phin_person.save
      params[:phin_person][:phin_roles].each do |role|
        pr = PhinRole.find(role)
        if pr.approvalRequired
          rr = RoleRequest.new
          rr.requester=@phin_person
          rr.role = pr
          rr.save!
        else
          if pr.uniqueMember.nil?
            pr.uniqueMember = [ActiveLdap::DistinguishedName.parse(@phin_person.dn)]
          elsif pr.uniqueMember.is_a?(Array)
            pr.uniqueMember << ActiveLdap::DistinguishedName.parse(@phin_person.dn)
          else
            pr.uniqueMember = [pr.uniqueMember, ActiveLdap::DistinguishedName.parse(@phin_person.dn)]
          end
          pr.save!
        end
      end
      if @phin_person.save
        respond_to do |format|
          flash[:notice] = 'PhinPerson was successfully created.'
          #TODO Fix redirect_to to accept ActiveLdap object
          format.html { redirect_to(:action => "show", :id => ActiveSupport::Base64.encode64(@phin_person.id)) }
          format.xml  { render :xml => @phin_person, :status => :created, :location => @phin_person }
        end
      else
        respond_to do |format|
          format.html { render :action => "new" }
          format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phin_people/1
  # PUT /phin_people/1.xml
  def update
    @phin_person = PhinPerson.find_with_encoded_id(params[:id])

    respond_to do |format|
      if @phin_person.update_attributes(params[:phin_person])
        flash[:notice] = 'PhinPerson was successfully updated.'
        format.html { redirect_to(@phin_person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phin_people/1
  # DELETE /phin_people/1.xml
  def destroy
    @phin_person = PhinPerson.find_with_encoded_id(params[:id])
    @phin_person.destroy

    respond_to do |format|
      format.html { redirect_to(phin_people_url) }
      format.xml  { head :ok }
    end
  end
end
