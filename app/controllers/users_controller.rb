class UsersController < ApplicationController
  
  before_filter :authenticate_user!
  
  respond_to :html, :json

  include DeviseHelper

  def visits_csv
    @user = current_user
    if @user.visits.present?
    respond_to do |format|
      format.csv { send_data @user.export_visits_to_csv }
    end
    else
      return
    end
  end

  def home
    if current_user 
      @new_user = User.new
      @user = current_user
      if @user.role < User::ROLE_REP
        @active_users = User.where("id != ?", @user.id).select { |user| user.confirmed? && user.same_institution?(@user) }
        @active_users = @active_users.sort_by!(&:created_at).reverse!
        @pending_users = User.select { |user| user.pending? && user.same_institution?(@user) } 
        @pending_users = @pending_users.sort_by!(&:created_at).reverse!
        @customer = Stripe::Customer.retrieve(@user.stripe_id) unless @user.account.payment_type != "Credit Card"
      end
      unless @user.institution_id.blank?
        @institution = Institution.find(@user.institution_id)
      end  
      
      @visits = @user.visits.select{|v| v.endDateTime.future? == true }.sort_by { |v| v[:startDateTime] }.take(10)
      
      @preferred_email = PreferredEmail.new

      @notes = @user.notes.order(created_at: :desc).limit(10)
      @note = Note.new
      @saved_searches = @user.saved_searches.order(created_at: :desc).limit(10)
    else 
      redirect_to new_user_session_url
    end  
  end  

  def index
    redirect_to home_users_url
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:update_user_message] = "An email has been sent to #{@user.unconfirmed_email}. Update pending confirmation."
      redirect_to '/#users'
    else
      flash[:error_user_message] = "The email address #{@user.errors[:email][0]}. Please try again."
      redirect_to '/#users'
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:destroy_user_message] = "#{user.first_name} #{user.last_name} has been deleted."
    redirect_to '/#users'
  end

  private

  def user_params
    params.require(:user).permit(:email, :role, :first_name, :last_name, :phone_num, :weekly_agenda, :institution_id, :password, :password_confirmation, :time_zone)
  end


end