class FoldersController < ApplicationController
  def create
    @folder = current_user.folders.build(params[:folder])
    @folder.save!
    redirect_to documents_path
  end
end
