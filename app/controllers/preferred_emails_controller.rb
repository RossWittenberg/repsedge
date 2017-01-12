class PreferredEmailsController < ApplicationController

  before_filter :authenticate_user! 

	def create
		@high_school = HighSchool.find(params[:preferred_email][:high_school_id])
		@user = current_user
		@preferred_email = PreferredEmail.new(preferred_email_params)
		if @preferred_email.save
			flash[:email_success] = "Your email contact for #{@high_school.name} has been added."
			respond_to do |format|
				format.html do
					redirect_to @high_school
				end
		  	format.js {render inline: "location.reload()" }
			end
		else
			flash[:email_errors] = @preferred_email.errors.messages
			respond_to do |format|
				format.html do
					redirect_to @high_school
				end
		  	format.js { render inline: "location.reload()" }
			end
		end	
	end

	def update
		@user = current_user
		@preferred_email = PreferredEmail.find(params[:id])
		@high_school = HighSchool.find(params[:preferred_email][:high_school_id])
		if @preferred_email.update(preferred_email_params)
			redirect_to @high_school
		else
			flash[:email_errors] = @preferred_email.errors.messages
			redirect_to @high_school
		end	
	end	


	def destroy
		@user = current_user
		@preferred_email = PreferredEmail.find(params[:id])
		@high_school = HighSchool.find(params[:high_school_id])
		@preferred_email.destroy
		redirect_to @high_school
	end	

private

	def preferred_email_params
	  params.require(:preferred_email).permit(:user_id, :address, :high_school_id)
	end

end