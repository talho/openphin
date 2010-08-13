class FavoritesController < ApplicationController



  def index
    respond_to do |format|
      format.xml {render :xml => current_user.favorites}
      format.json {render :json => current_user.favorites}
    end
  end

  # we're not defining a new here because this is only intended to be used with an AJAX call. Same for edit
  def create
    fav = Favorite.new(:user_id => current_user.id, :tab_config => params[:favorite][:tab_config])

    respond_to do |format|
      if fav.save!
        format.xml {render :xml => fav, :status => :created}
        format.json {render :json => fav, :status => :created}
      else
        format.xml {render :xml => fav.errors, :status => 500}
        format.json {render :json => fav.errors, :status => 500}
      end
    end
  end

  def destroy
    fav = Favorite.find(params[:id])

    respond_to do |format|
      if fav.user_id != current_user.id
        format.xml {render :xml => "Could not destroy favorite: not owned by current user.", :status => :forbidden}
        format.json {render :json => "Could not destroy favorite: not owned by current user.", :status => :forbidden}
      elsif fav.destroy
        format.xml {render :xml => nil}
        format.json {render :json => nil}
      else
        format.xml {render :xml => fav.errors, :status => 500}
        format.json {render :json => fav.errors, :status => 500}
      end
    end
  end
end
