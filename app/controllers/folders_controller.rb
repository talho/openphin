class FoldersController < ApplicationController
  def create
    @folder = current_user.folders.build(params[:folder])
    @folder.save!
    @folder.move_to_child_of(current_user.folders.find(params[:folder][:parent_id])) unless params[:folder][:parent_id].blank?
    redirect_to documents_path
  end
  
  def show
    @folder = current_user.folders.find(params[:id])
    @documents = @folder.documents
    render 'documents/index'
  end
end
