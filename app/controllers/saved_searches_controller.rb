class SavedSearchesController < ApplicationController

  before_filter :authenticate_user! 

	def create
		@user = User.find(params[:user_id])
		@saved_search = @user.saved_searches.new(saved_search_params)
		if @saved_search.save
			@saved_searches = @user.saved_searches
			flash[:search] = "Your search has been saved."
	  	respond_to do |format|
			  format.js {render inline: "location.reload();" }
			end
	  else
	  	@errors_string = "Your search was not saved. " + @saved_search.errors.full_messages.to_sentence
	  	respond_to do |format|
			  format.json { render json: @errors_string }
			end
	  end	
	end  	

	def destroy
	  @saved_search = SavedSearch.find(params[:id])
	  @saved_search.destroy
		@user = User.find(params[:user_id])
		@saved_searches = @user.saved_searches
  	respond_to do |format|
		  format.js {render inline: "location.reload()" }
		end
	end

	private

	def saved_search_params
	  params.require(:saved_search).permit(:name, :query_string, :user_id)
  end

end