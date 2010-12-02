class Doc::DocumentsController < ApplicationController
  before_filter :non_public_role_required, :change_include_root
  before_filter :can_edit_document, :only => [:edit, :move, :destroy]
  after_filter :change_include_root_back

  def show
    @document = Document.find(params[:id]).viewable_by(current_user)
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment', :x_sendfile => request.env["SERVER_SOFTWARE"].downcase.match(/apache/) ? true : false
  end

  def create
    begin
      params[:document][:folder_id] = nil if params[:document][:folder_id] == 'null' || params[:document][:folder_id] == '' || params[:document][:folder_id] == '0'

      @parent_folder = params[:document][:folder_id] ?  Folder.find(params[:document][:folder_id].to_i) : nil

      #check to make sure the user can write to this folder here
      unless @parent_folder.nil? || @parent_folder.author?(current_user)
        respond_to do |format|
          format.json { render :json => {:success => false, :msg => "Current user does not have permission to create this file."}, :content_type => 'text/html', :status => 401 }
        end
        return
      end

      unless (@parent_folder ? @parent_folder.documents : current_user.documents.inbox).detect{|x| x.file_file_name == params[:document][:file].original_filename}
        @document = (@parent_folder ? @parent_folder.owner.documents : current_user.documents).build(params[:document])
        @document.owner_id = (@parent_folder ? @parent_folder.owner.id : current_user.id)
        if @document.valid?
          @document.save!
          respond_to do |format|
            format.json {render :json => {:success => true }, :content_type => 'text/html' }
          end
        else
          respond_to do |format|
            format.json {render :json => {:msg => @document.errors["file"].as_json, :success => false }, :content_type => 'text/html', :status => 400 }
          end
          return
        end
      else
        respond_to do |format|
          format.json {render :json => {:msg => 'File name is already in use. Try renaming the file.', :success => false }, :content_type => 'text/html', :status => 409 }
        end
        return
      end
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:msg => 'An error occurred while saving the document. An administrator has been notified.', :error => e.to_s, :backtrace => e.backtrace, :success => false }, :content_type => 'text/html', :status => 409 }
      end
    end
  end

  def edit
    @document = Document.find(params[:id]).editable_by(current_user)
  end

  def update
    begin
      @document = Document.find(params[:id]).editable_by(current_user)
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:msg => 'Could not find the document specified.', :error => e.to_s, :backtrace => e.backtrace, :success => false }, :content_type => 'text/html', :status => 409 }
      end
      return
    end

    respond_to do |format|
      if !@document
        # render that the user was unable to edit the document
        format.json {render :json => { :msg => 'You do not have permission to change this document.', :success => false }, :content_type => 'text/html', :status => 401 }
        return
      end

      if (@document.folder ? @document.folder.documents : current_user.documents.inbox).detect {|x| x != @document && params[:document][:file] && x.file_file_name == params[:document][:file].original_filename }
        # render that the user needs to select a different file because this already exists
        format.json {render :json => {:msg => 'A file with this name already exists in the folder, please select a file with a unique name.', :success => false }, :content_type => 'text/html', :status => 400 }
      end

      if @document.update_attributes(params[:document])
         format.json {render :json => {:success => true}, :content_type => 'text/html' }
      else
        #render that there was some sort of error
        format.json {render :json => { :success => false, :msg => "An unknown error occurred", :errors => @document.errors }, :status => 400, :content_type => 'text/html' }
      end
    end
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      respond_to do |format|
        format.json { render :json => {:success => true } }
      end
    else
      respond_to do |format|
        format.json {render :json => {:success => false, :msg => "An unknown error occurred", :errors => @document.errors }, :status => 400 }
      end
    end
  end

  def move
    document = Document.find(params[:id])

    params[:parent_id] = nil if params[:parent_id] == 'null' || params[:parent_id] == ''

    document.folder_id = params[:parent_id]

    if document.save!
      respond_to do |format|
        format.json { render :json => {:success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => {:success => false, :errors => document.errors }, :status => 400 }
      end
    end
  end

  def copy
    document = Document.find(params[:id])
    folder = params[:parent_id].blank? ? nil : Folder.find(params[:parent_id])

    unless document.audience.recipients.with_no_hacc.include?(current_user)
      respond_to do |format|
        format.json { render :json => { :msg => 'Current user does not have permission to modify this document.', :success => false}, :status => 401}
      end
      return
    end
    
    document.copy(current_user, folder)

    respond_to do |format|
      format.json {render :json => {:success => true} }
    end
  end

  def can_edit_document
    document = Document.find(params[:id])
    unless document.editable_by?(current_user)
      respond_to do |format|
        format.json { render :json => { :msg => 'Current user does not have permission to modify this document.', :success => false}, :status => 401}
      end
      false
    end
  end
end
