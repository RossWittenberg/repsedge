class NotesController < ApplicationController

  before_filter :authenticate_user!

	def all_notes
		@user = User.find params[:user_id]
		@notes = @user.notes.order(created_at: :desc).paginate(:page => params[:page], :per_page => 20)
	end

	def index
		@user = User.find(params[:user_id])
		@high_school = HighSchool.find(params[:high_school_id])
		@notes = @user.notes.all.where("high_school_id = #{@high_school.id}").order(created_at: :desc).limit(5)
	end

	def create
		@high_school = HighSchool.find(params[:note][:high_school_id])
		@user = User.find params[:user_id]
		@note = Note.new(note_params)
		if @note.save
			# redirect_to @high_school
			flash[:notes_success] = "Your note on #{@high_school.name} has been added."
			respond_to do |format|
		  	format.js {render inline: "location.reload()" }
			end
		else
			flash[:notes_error] = @note.errors.full_messages[0]
			redirect_to @high_school
		end	
	end

	def update
		@user = User.find(params[:user_id])
		@note = Note.find(params[:id])
		@high_school = @note.high_school
		if @note.update(note_params)
			flash[:notes_success] = "Your note on #{@high_school.name} has been updated."
			redirect_to all_notes_user_high_schools_path
		else
			flash[:notes_success] = "Your note must have content to be updated."
			redirect_to @high_school
		end	
	end	

	def destroy
	  @note = Note.find(params[:id])
	  if @note.destroy
			@user = User.find(params[:user_id])
			@notes = @user.notes
			flash[:deleted] = "Your note has been deleted."
  		respond_to do |format|
		  	format.js {render inline: "location.reload()" }
			end
		end	
	end

	def keyword_search
		search = Note.searchNotes(params[:keyword_query], current_user)
		@user = current_user
		if search.results.blank?
	  	flash[:search] = "The search parameters you selected yielded no results. Please modify your search and try again."
		else
			@search = search
	  end
	end

private

	def note_params
	  params.require(:note).permit(:user_id, :content, :time_tag, :high_school_id)
	end

end