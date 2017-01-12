class ConfirmationsController < Devise::ConfirmationsController

   def update
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        @confirmable.attempt_set_password(params[:user])
        if @confirmable.valid? and @confirmable.password_match?( params[:user][:password], params[:user][:password_confirmation] )
          do_confirm
        else
          do_show
          @confirmable.errors.clear 
        end
      else
        @confirmable.errors.add(:email, :password_already_set)
      end
    end

    if !@confirmable.errors.empty?
      self.resource = @confirmable
      render 'devise/confirmations/new'
    end
  end

  def show
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        do_show
      else
        do_confirm
      end
    end
    if !@confirmable.errors.empty?
      self.resource = @confirmable
      render 'devise/confirmations/new' #Change this if you don't have the views on default path 
    end
  end

  def confirm_account
    @account = User.find(params[:account][:confirmation_token])
    if @account.update_attributes(params[:account]) and @account.password_match?
      @account = User.confirm_by_token(@account.confirmation_token)
      set_flash_message :notice, :confirmed      
      sign_in_and_redirect("user", @account)
    else
      render :action => "show"
    end
  end

  protected

  def with_unconfirmed_confirmable
    original_token = params[:confirmation_token]
    confirmation_token = Devise.token_generator.digest(User, :confirmation_token, original_token)
    @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
    if !@confirmable.new_record?
      @confirmable.only_if_unconfirmed {yield}
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    render 'devise/confirmations/show' #Change this if you don't have the views on default path
  end

  def do_confirm
    @confirmable.confirm!
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end


  def after_confirmation_path_for(resource_name, resource)
    flash[:confirmation] = "Your account has been confirmed. Welcome to RepsEdge!"
    '/'
  end

  def after_resending_confirmation_instructions_path_for(resource_name)
    flash[:confirmation] = "Confirmation resent to #{resource.email}"
    '/#users'
  end

end