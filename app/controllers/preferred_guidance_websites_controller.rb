class PreferredGuidanceWebsitesController < ApplicationController

  before_filter :authenticate_user!

	def create
		@high_school = HighSchool.find(params[:preferred_guidance_website][:high_school_id])
		@user = current_user
		@preferred_guidance_website = PreferredGuidanceWebsite.new(preferred_guidance_website_params)
		if @user.preferred_guidance_websites.where("high_school_id = #{@high_school.id}").count < 1
			if @preferred_guidance_website.save 
				@high_school = HighSchool.find @preferred_guidance_website.high_school_id
				redirect_to @high_school
			else
				flash[:website] = @preferred_guidance_website.errors.messages
				redirect_to @high_school 
			end
		else
			if @user.preferred_guidance_websites.where("high_school_id = #{@high_school.id}").count >= 1
				@preferred_guidance_website.errors.add(:address, "You can only have one guidance website per school.")
			end
			flash[:website] = @preferred_guidance_website.errors.messages
			redirect_to @high_school 
		end	
	end

	def update
		@user = current_user
		@preferred_guidance_website = PreferredGuidanceWebsite.find(params[:id])
		@high_school = HighSchool.find(params[:preferred_guidance_website][:high_school_id])
		if @preferred_guidance_website.update(preferred_guidance_website_params)
			redirect_to @high_school
		else
			flash[:website] = @preferred_guidance_website.errors.messages
			redirect_to @high_school
		end	
	end	

	def destroy
		@user = current_user
		@preferred_guidance_website = PreferredGuidanceWebsite.find(params[:id])
		@high_school = HighSchool.find(params[:high_school_id])
		@preferred_guidance_website.destroy
		redirect_to @high_school
	end	

private

	def preferred_guidance_website_params
	  params.require(:preferred_guidance_website).permit(:user_id, :url, :high_school_id)
	end

end