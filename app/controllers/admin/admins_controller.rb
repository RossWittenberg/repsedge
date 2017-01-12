class Admin::AdminsController < ApplicationController

  include DeviseHelper

  before_filter :authenticate_user! && :authenticate_admin

	def edit
		@institutions = Institution::ALL_INSTITUTIONS
	  @states = State::ALL_STATES
	  # State::ALL_STATES.map { |state| @states.push(state.name) }
	  @user = User.find params[:id]
	end

	def new
    @user = User.new
	end

	def create
		@user = User.new(admin_user_attrs(admin_user_params))
		@user.institution = admin_user_institution_name(admin_user_params)
		@user.account = Account.create(admin_user_account_attrs(admin_user_params))
		if @user.institution.blank?
      redirect_to '/admin/high_schools/dashboard#admins', notice: "You must select and institution to create a new user."
		else	
			if @user.institution && @user.save
	      redirect_to '/admin/high_schools/dashboard#admins', notice: "#{@user.first_name} #{@user.last_name} was successfully created."
			else
				@institutions = Institution::ALL_INSTITUTIONS
	    	@states = State::ALL_STATES
	      render action: "new", notice: @user.errors.full_messages
			end
		end	
	end

	def update
		@user = User.find params[:id]
		# @user.account.update(admin_update_user_account_attrs(admin_user_params)) if @user.account
		resource = @user
    if params[:user][:current_password].present?
      if resource.valid_password?(params[:user][:current_password])
        result = resource.update_with_password(admin_update_user_attrs(admin_user_params))
      	flash.notice = "#{@user.first_name} #{@user.last_name} was successfully updated."
	    	redirect_to '/admin/high_schools/dashboard#admins'
      else  
      	flash.notice = "Password is incorrect"
      	redirect_to edit_admin_path(@user)
      end
    else
      if resource.update_without_password(admin_update_user_attrs(admin_user_params))
   	  	flash.notice = "#{@user.first_name} #{@user.last_name} was successfully updated."
	    	redirect_to '/admin/high_schools/dashboard#admins'
    	else
    		flash.now[:admin] = @user.errors.full_messages
        render action: "edit"
    	end
    end

	end


	def destroy
    @user = User.find(params[:id])
    notice = "User #{@user.first_name} #{@user.last_name} was successfully deleted."
    if @user.destroy
      redirect_to '/admin/high_schools/dashboard#admins', notice: notice
		end
	end
	  
	private

	def authenticate_admin
    if current_user && current_user.account_admin?
      return
    else
      redirect_to root_path
    end    
  end

	def admin_user_params
		params.permit( :utf8, :_method, :utf, :authenticity_token, :role, :commit, :method, :controller, :action, :id, :state,
									 institution:[:name], 
									 user:[:first_name, :phone_num, :last_name, :email, :password, :password_confirmation, :current_password],
									 account:[:is_paid, :plan_years, :payment_type, :billing_street_address_line_1, :billing_street_address_line_2, :billing_city, :billing_state, :billing_zip_code, :plan_price, :plan_level] )
	end
	
	# def admin_user_params
	# 	params.permit( :utf8, :_method, :utf, :authenticity_token, :role, :commit, :method, :controller, :action, :users_admin_id, :state,
	# 								 institution:[:name], 
	# 								 user:[:first_name, :phone_num, :last_name, :email, :password, :password_confirmation],
	# 								 account:[:is_paid, :plan_years, :payment_type, :billing_street_address_line_1, :billing_street_address_line_2, :billing_city, :billing_state, :billing_zip_code, :plan_price, :plan_level] )
	# end

	def admin_user_attrs(admin_user_params)
		admin_user_attrs = admin_user_params[:user]
		admin_user_attrs[:role] = 0
		return admin_user_attrs
	end

	# def admin_user_account_attrs(admin_user_params)
	# 	admin_user_account_attrs = admin_user_params[:account]
	# 	return admin_user_account_attrs
	# end

	def admin_user_account_attrs(admin_user_params)
		admin_user_account_attrs = { plan_years: 3,
																 is_recurring: false,
																 is_paid: true,
																 plan_price: 0,
																 plan_level: "RepsEdge",
																 billing_city: "Malverne",
																 billing_state: "New York",
																 billing_zip_code: "11565",
																 payment_type: "Admin Account",
																 billing_street_address_line_1: "P.O. Box 281" }
		return admin_user_account_attrs
	end
	
	# def admin_user_institution_name(admin_user_params)	
	# 	admin_user_institution_name = admin_user_params[:institution]["name"]
	# 	return admin_user_institution_name
	# end

	def admin_update_user_attrs(admin_user_params)
		admin_update_user_attrs = admin_user_params[:user]
		admin_update_user_attrs[:role] = 0
		return admin_update_user_attrs
	end

	def admin_update_user_account_attrs(admin_user_params)
		admin_update_user_account_attrs = admin_user_params[:account]
		return admin_update_user_account_attrs
	end

	def admin_update_user_institution_name(admin_user_params)	
		admin_update_user_institution_name = admin_user_params[:institution]["name"]
		return admin_update_user_institution_name
	end

	def admin_user_institution_name(admin_user_params)	
		admin_user_institution_name = Institution.find_by name: "RepsEdge"
		return admin_user_institution_name
	end




end