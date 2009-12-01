class FoldersController < ApplicationController
  before_filter :non_public_role_required
  layout nil

  def create
    @folder = current_user.folders.build(params[:folder])
    @folder.save!
    @folder.move_to_child_of(current_user.folders.find(params[:folder][:parent_id])) unless params[:folder][:parent_id].blank?
    redirect_to documents_panel_path
  end
  
  def show
    @folder = current_user.folders.find(params[:id])
    @documents = @folder.documents
  end
  
  def destroy
    folders = current_user.folders
    folder = folders.find(params[:id])
    if !folder.nil? && folder.destroy 
      flash[:notice] = "Successfully removed the folder"
    else
      flash[:error] = "Could not remove the document."
    end
      redirect_to documents_path
  end
end
                  