class Admin::AccountsController < ApplicationController

  include DeviseHelper
  before_filter :authenticate_user! && :authenticate_admin

	def edit
		@institutions = Institution::ALL_INSTITUTIONS
	  @states = State::ALL_STATES
		@account = Account.find params[:id]
	end

  def new
    @institutions = Institution::ALL_INSTITUTIONS
    @states = State::ALL_STATES
    @user = User.new
    @account = Account.new
  end

  def create
    if params[:user][:institution].blank?
      @institutions = Institution::ALL_INSTITUTIONS
      @states = State::ALL_STATES
      @user = User.new
      @account = Account.new
      flash.now[:admin] = "You must select an institution to create a new account."
      render action: "new"
    else  
      @states = State::ALL_STATES
      @account = Account.new(account_attrs(account_params))
      @user = User.new(user_attrs(account_params))
      if @account.save && @user.save
        @account.user = @user
        @account.save
        @user.skip_confirmation!
        @user.save
        @user.send_new_account_from_admin_email
        redirect_to dashboard_admin_high_schools_path, notice: "#{@account.user.first_name} #{@account.user.last_name}'s account was successfully created."
      else
        errors = []
        errors.push(@account.errors.full_messages)
        errors.push(@user.errors.full_messages)
        render action: "new", notice: errors
      end
    end  
  end

	def update
    @account = Account.find(params[:id])
    @states = State::ALL_STATES
    @user = (Account.find params[:id]).user
    @user.update(user_attrs(account_params))
    @account.update(account_attrs(account_params))
    errors = []
    if params[:user] && params[:user][:institution] && params[:user][:institution] != nil
	  	@institution = Institution.find_by name: params[:user][:institution]
	  	@user = (Account.find params[:id]).user
	  	@user.update_attributes({institution: @institution})
      redirect_to "/admin/high_schools/dashboard#accounts", notice: "#{@account.user.first_name} #{@account.user.last_name}'s institution has been updated."
      return
    end
    
    
    unless @user.save 
      errors << @user.errors.full_messages
    end

    unless @account.save
      errors << @account.errors.full_messages
    end

    if @user.save && @account.save
      redirect_to "/admin/high_schools/dashboard#accounts", notice: "#{@account.user.first_name} #{@account.user.last_name}'s account was successfully updated."
      # flash.now[:admin] = @account.errors.full_messages
    else
      flash.now[:admin] = errors
      render action: "edit"
    end

  end

	def destroy
    @account = Account.find(params[:id])
    notice = "#{@account.user.first_name} #{@account.user.last_name}'s was successfully deleted."
    if @account.destroy && @account.user.destroy
      redirect_to "/admin/high_schools/dashboard#accounts", notice: notice
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

	def account_params
	  params.permit( :utf8, :_method, :method, :authenticity_token, :commit, :id, :action, :controller, :state, 
                   user:[ :institution, :first_name, :last_name, :email, :phone_num ],
                   account: [ :payment_type, :plan_years, :is_recurring, :is_paid, :billing_street_address_line_1, :billing_street_address_line_2, :billing_city, :billing_state, :billing_zip_code, user:[ :password, :password_confirmation ]])
  end

  def account_attrs(account_params)
    account_attrs = account_params.clone
    account_attrs[:account].delete :user
		return account_attrs[:account]
	end

  def user_attrs(account_params)
    user_attrs = account_params[:user].clone
    if account_params[:account] && account_params[:account][:user] && account_params[:account][:user]["password"]
      user_attrs[:password] = account_params[:account][:user]["password"]
      user_attrs[:password_confirmation]= account_params[:account][:user]["password_confirmation"]
      user_attrs[:role] = 1
    end
    if user_attrs[:institution].present?
      user_attrs[:institution_id] = (Institution.find_by name: user_attrs[:institution]).id
      user_attrs.delete :institution
      return user_attrs
    end
    return user_attrs
  end
end






