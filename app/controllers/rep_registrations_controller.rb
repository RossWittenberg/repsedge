class RepRegistrationsController < Devise::RegistrationsController
	
  before_filter :authenticate_user! 
	
	def create
		@user = User.new(rep_registration_params)
		@user.role = User::ROLE_REP
		@user.institution = current_user.institution
		if @user.save
			@user.send_confirmation_instructions
			if current_user.role < User::ROLE_REP
        @active_users = User.where("id != ?", current_user.id).select { |user| user.confirmed? && user.same_institution?(@user) }
        @active_users = @active_users.sort_by!(&:created_at).reverse!
        @pending_users = User.select { |user| user.pending? && user.same_institution?(@user) } 
        @pending_users = @pending_users.sort_by!(&:created_at).reverse!
			flash[:create_user_message] = "An invitation to RepsEdge was sent to #{@user.first_name} #{@user.last_name} at #{@user.email}."
    	redirect_to '/#users', :status => 301								
      end
		else
			logger.info @user.errors.to_hash
			render :json => {:errors => @user.errors.to_hash }, :status => 422
		end	
	end	

	private

	def rep_registration_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone_num, :weekly_agenda )
  end

end