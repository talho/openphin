class Admin::InvitationsController < ApplicationController
  require 'fastercsv'

  def index
  end
  
  def show
  end
  
  def new
    @invitation = Invitation.new
  end
  
  def create
    paramsWithCSVInvitees unless params[:invitation][:csvfile].blank?
    params[:invitation].delete("csvfile")
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      flash[:notice] = "Invitation was successfully sent."
      redirect_to admin_invitation_path(@invitation)
    end
  end
  
  def destroy
  end

  private
  def paramsWithCSVInvitees
    csvfile = params[:invitation][:csvfile]
    newfile = File.join(Rails.root,'tmp',csvfile.original_filename)
    File.open(newfile,'wb') do |file|
      file.puts csvfile.read
    end
    next_index = 0

    params[:invitation][:invitees_attributes].each do |key, value|
      next_index = key.to_i + 1 if key.to_i >= next_index
    end unless params[:invitation][:invitees_attributes].blank?
    FasterCSV.open(newfile, :col_sep => "|", :headers => true) do |records|
      records.each do |record|
        params[:invitation][:invitees_attributes] = [] if params[:invitation][:invitees_attributes].blank?
        params[:invitation][:invitees_attributes]["#{next_index}"] = {}
        params[:invitation][:invitees_attributes]["#{next_index}"][:name] = record["name"]
        params[:invitation][:invitees_attributes]["#{next_index}"][:email] = record["email"]
        next_index += 1
      end
    end
  end
  
end
