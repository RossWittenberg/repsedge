class RegistrationsController < Devise::RegistrationsController
  
  include DeviseHelper	

  include VisitsHelper

  respond_to :html, :json

  def new
    @institutions = Institution::ALL_INSTITUTIONS
    @states = State::ALL_STATES
  end

  def checkout
    @institutions = Institution::ALL_INSTITUTIONS
    @states = State::ALL_STATES
    @institution = Institution.find_by name: params[:user][:institution]
    if @institution.blank?
      flash.now[:no_institution] = "The institution you have entered can not be found in our database. Please try retyping the institution in, or contact sales@repsedge.com for assistance."
      render :new
    else 
      build_resource({})
      set_minimum_password_length
      yield resource if block_given?
      @user = self.resource
      resource.institution = @institution
      respond_with self.resource
    end
  end

  def create
    build_resource(user_attrs)
    resource.account = Account.new(account_attrs)
    if resource.save && resource.account.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        expire_data_after_sign_in!
        render :json => { user: resource, institution: resource.institution, account: resource.account }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      errors_hash = (resource.errors.to_hash).merge!(resource.account.errors.to_hash)
      render :json => {:errors => errors_hash }, :status => 422
    end		
  end

  def update

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    if params[:calendar] && params[:user]
      result = resource.update_without_password(account_update_params)
      @user = resource
      @visits = @user.visits
      @new_visit = Visit.new
      respond_to do |format|
        format.json { render json: @visits, each_serializer: VisitSerializer }
        format.html { render "index", user: @user, visits: @visits }
      end
    else  
      if params[:user][:current_password].present?
        if resource.valid_password?(params[:user][:current_password])
          result = resource.update_with_password(account_update_params)
        else  
          @current_password_error = {current_password_error: "Password is incorrect"}
        end
      else
        result = resource.update_without_password(account_update_params)
      end

      if result && resource.confirmation_sent_at
        flash[:update_user_message] = "#{resource.first_name} #{resource.last_name} account has been updated. Changes to email will require confirmation before taking effect."
        sign_in resource_name, resource, bypass: true
        redirect_to '/#settings', status: 200
      elsif result
        flash[:update_user_message] = "#{resource.first_name} #{resource.last_name} has been updated."
        sign_in resource_name, resource, bypass: true
        redirect_to '/#settings', status: 200
      else
        clean_up_passwords resource
        render json: { errors: @user.errors.to_hash, current_password_error: @current_password_error  }, :status => 422
      end
    end 
  end

  private

  def user_params
	  params.require(:user).permit(:role,
                                 :first_name,
                                 :last_name,
                                 :weekly_agenda,
                                 :email,
                                 :email_confirmation,
                                 :password,
                                 :password_confirmation,
                                 :current_password,
                                 :phone_num,
                                 :institution,
                                 :plan_years,
                                 :plan_price,
                                 :plan_level,
                                 :billing_street_address_line_1, 
                                 :billing_street_address_line_2,
                                 :billing_city,
                                 :billing_state,
                                 :billing_zip_code,
                                 :time_zone  )
	end

  def account_params
    params.require(:user).permit( :role,
                                  :first_name,
                                  :last_name,
                                  :weekly_agenda,
                                  :email,
                                  :email_confirmation,
                                  :password,
                                  :password_confirmation,
                                  :current_password,
                                  :phone_num,
                                  :institution,
                                  :plan_years,
                                  :plan_price,
                                  :plan_level,
                                  :billing_street_address_line_1, 
                                  :billing_street_address_line_2,
                                  :billing_city,
                                  :billing_state,
                                  :billing_zip_code,
                                  :time_zone )
  end

	def after_inactive_sign_up_path_for(resource)
    new_account_path(user: resource)
  end

  def set_minimum_password_length
    if devise_mapping.validatable?
      @minimum_password_length = resource_class.password_length.min
    end
  end

  def user_attrs
    user_attrs = user_params.clone
    institution = Institution.find_by name: user_attrs[:institution]
    user_attrs[:institution_id] = institution.id
    user_attrs.delete :institution
    user_attrs.delete :plan_years
    user_attrs.delete :plan_price
    user_attrs.delete :plan_level
    user_attrs.delete :billing_street_address_line_1
    user_attrs.delete :billing_street_address_line_2
    user_attrs.delete :billing_city
    user_attrs.delete :billing_state
    user_attrs.delete :billing_zip_code
    return user_attrs
  end  

  def account_attrs
    account_attrs = account_params.clone
    account_attrs[:is_recurring] = false
    account_attrs[:is_paid] = false
    account_attrs.delete :role
    account_attrs.delete :first_name
    account_attrs.delete :last_name
    account_attrs.delete :weekly_agenda
    account_attrs.delete :email
    account_attrs.delete :email_confirmation
    account_attrs.delete :password
    account_attrs.delete :password_confirmation
    account_attrs.delete :current_password
    account_attrs.delete :phone_num
    account_attrs.delete :institution
    account_attrs.delete :time_zone
    return account_attrs
  end


  def account_update_params
    params.require(:user).permit(:role,
                                 :first_name,
                                 :last_name,
                                 :weekly_agenda,
                                 :email,
                                 :email_confirmation,
                                 :password,
                                 :password_confirmation,
                                 :current_password,
                                 :phone_num,
                                 :institution,
                                 :plan_years,
                                 :plan_price,
                                 :plan_level,
                                 :billing_street_address_line_1, 
                                 :billing_street_address_line_2,
                                 :billing_city,
                                 :billing_state,
                                 :billing_zip_code,
                                 :time_zone )
  end

end 

