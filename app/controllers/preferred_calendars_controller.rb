class PreferredCalendarsController < ApplicationController

  before_filter :authenticate_user!

	def create
		@high_school = HighSchool.find(params[:preferred_calendar][:high_school_id])
		@user = current_user
		@preferred_calendar = PreferredCalendar.new(preferred_calendar_params)
		if @user.preferred_calendars.where("high_school_id = #{@high_school.id}").count < 1
			if @preferred_calendar.save
				@user.send_calendar_url_notification(@high_school)
				redirect_to @high_school
			else
				flash[:calendar_url] = @preferred_calendar.errors.messages
				redirect_to @high_school 
			end
		else
			if @user.preferred_calendars.where("high_school_id = #{@high_school.id}").count >= 1
				@preferred_calendar.errors.add(:address, "You can only have one calendar website per school.")
			end
			flash[:calendar_url] = @preferred_calendar.errors.messages
			redirect_to @high_school 
		end	
	end

	def update
		@user = current_user
		@preferred_calendar = PreferredCalendar.find(params[:id])
		@high_school = HighSchool.find(params[:preferred_calendar][:high_school_id])
		if @preferred_calendar.update(preferred_calendar_params)
			redirect_to @high_school
		else
			flash[:calendar_url] = @preferred_calendar.errors.messages
			redirect_to @high_school
		end	
	end	


	def destroy
		@user = current_user
		@preferred_calendar = PreferredCalendar.find(params[:id])
		@high_school = HighSchool.find(params[:high_school_id])
		@preferred_calendar.destroy
		redirect_to @high_school
	end	

private

	def preferred_calendar_params
	  params.require(:preferred_calendar).permit(:user_id, :url, :high_school_id)
	end

end