class PreferredPhonesController < ApplicationController

  before_filter :authenticate_user!

	def create
		@high_school = HighSchool.find(params[:preferred_phone][:high_school_id])
		@user = current_user
		@preferred_phone = PreferredPhone.new(preferred_phone_params)
		if @preferred_phone.save
			redirect_to @high_school
		else
			flash[:phone_errors] = @preferred_phone.errors.messages
			redirect_to @high_school
		end	
	end

	def create
		@high_school = HighSchool.find(params[:preferred_phone][:high_school_id])
		@user = current_user
		@preferred_phone = PreferredPhone.new(preferred_phone_params)
		if @user.preferred_phones.where("high_school_id = #{@high_school.id}").count < 1
			if @preferred_phone.save 
				redirect_to @high_school
			else
				flash[:phone_errors] = @preferred_phone.errors.messages
				redirect_to @high_school 
			end
		else
			if @user.preferred_phones.where("high_school_id = #{@high_school.id}").count >= 1
				@preferred_phone.errors.add(:address, "You can only have one preferred guidance phone number per school.")
			end
			flash[:phone_errors] = @preferred_phone.errors.messages
			redirect_to @high_school 
		end	
	end

	def update
		@user = current_user
		@preferred_phone = PreferredPhone.find(params[:id])
		@high_school = HighSchool.find(params[:preferred_phone][:high_school_id])
		if @preferred_phone.update(preferred_phone_params)
			redirect_to @high_school
		else
			flash[:phone_errors] = @preferred_phone.errors.messages[0]
			redirect_to @high_school
		end	
	end	

	def destroy
		@user = current_user
		@preferred_phone = PreferredPhone.find(params[:id])
		@high_school = HighSchool.find(params[:high_school_id])
		@preferred_phone.destroy
		redirect_to @high_school
	end	

private

	def preferred_phone_params
	  params.require(:preferred_phone).permit(:user_id, :num, :extension, :high_school_id)
	end

end


def exclude_att(attribute, error_msg)
  if attribute.to_s == "Num"
    error_msg
  else
    attribute.to_s.humanize + " " + error_msg
  end
end