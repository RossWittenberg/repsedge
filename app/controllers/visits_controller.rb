class VisitsController < ApplicationController

  include VisitsHelper

  before_filter :authenticate_user! 

  before_filter :force_html, only: :index

	def index
    @user = User.find params[:user_id]
    @visits = @user.visits.includes(:high_school, user: [:preferred_phones])
    @new_visit = Visit.new
    respond_to do |format|
      format.json { render json: @visits, each_serializer: VisitSerializer }
      format.html { render "index", user: @user }
    end
  end

  def calendar_feed
    @user = User.find(params[:user_id])
    @visits = @user.visits
    respond_to do |format|
      format.ics
    end
  end  

  def share
    @user = current_user
    if valid_email?(params[:email])
      flash[:share_success] = "Your weekly agenda has been sent to #{params[:email]}"
      @user.send_share_weekly_agenda(params[:email])
    else
      flash[:share_error] = "Please enter a valid email address"
    end
    redirect_to user_visits_path(@user) 
  end
  
  def agenda
    @user = current_user
    @visits = @user.visits.where(start: (Time.now.midnight - 1.day)..Time.now + 7.days).order(created_at: :desc)
  end
 
  def edit
    @user = User.find(params[:user_id])
    @visit = Visit.find(params[:id])
    respond_to do |format|
      format.json { render json: @visit, serializer: VisitSerializer }
    end
  end

  def destroy
    @user = current_user
    @visit = @user.visits.find(params[:id])
    if @visit.destroy
      flash[:calendar] = "Your calendar event "+'"'+"#{@visit.title}"+'"' + " has been deleted."
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    else  
      flash[:calendar] = "There was a problem deleting #{@visit.title}, please try again."
    end
  end
 
  def create
    @user = User.find(params[:user_id])
    @visit = @user.visits.new(visit_attrs(visit_params))
    @visits = @user.visits
    (@visit.confirmed = params[:commit] == "Save as Confirmed" ?  true : false) if params[:commit]
    if @visit.save
      flash[:calendar_success] = "Your calendar event #{@visit.title} has been added to your calendar."
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    else
      flash[:calendar_errors] = @visit.errors.full_messages
      respond_to do |format|
        format.js { render inline: "location.reload();" }
      end
    end
  end

  def jsDragUpdate
    @user = User.find(params[:user_id])
    @visit = @user.visits.find(params[:visit_id])
    if @visit.addStartAndEndDateTimes(visit_drag_attrs(visit_params))
      @visits = @user.visits
      respond_to do |format|
        format.json { render json: @visits, each_serializer: VisitSerializer }
        format.html { redirect_to action: "index", id: @user.id }
      end
    else
      flash.alert = @visit.errors.full_messages.to_sentence
      redirect_to "index", user: @user, visit: @visit
    end 
  end   
    
  def formUpdate  
    @user = User.find(params[:user_id])
    @visit = @user.visits.find(params[:visit_id])
    if @visit.addStartAndEndDateTimes(visit_attrs(visit_params)) && @visit.errors.blank?

      @visits = @user.visits
      flash[:calendar_update] = "Your calendar event #{@visit.title} has been updated."
      respond_to do |format|
        format.json { render json: @visits, each_serializer: VisitSerializer }
        format.html { redirect_to action: "index" }
      end
    elsif @visit.errors
      flash[:calendar_update_errors] = @visit.errors.full_messages
      respond_to do |format|
        format.json { render json: @visits, each_serializer: VisitSerializer }
        format.html { redirect_to action: "index" }
      end
    else
      flash[:calendar_update] = "Your calendar event #{@visit.title} has been updated."
      redirect_to "index", user: @user, visit: @visit
    end
  end

  def update_confirmed
    @visit = Visit.find params[:visit_id]
    if @visit.update_attributes({ confirmed: params[:confirmed]})
      flash[:calendar_success] = "Your calendar event #{@visit.title} has been updated."
      respond_to do |format|
        format.js {render inline: "location.reload();" }
      end
    else
      flash[:calendar_errors] = "Something went wrong. Please try again."
      respond_to do |format|
        format.js { render inline: "location.reload();" }
      end
    end
  end  

	private

  def valid_email?(email)
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    email.present? && (email =~ email_regex)
  end

	def visit_params
    params.require(:visit).permit(:title, :location, :description, :category, :start, :end, :start_date_raw, 'start_time_raw(4i)', 'start_time_raw(5i)', :end_time_raw, :end_date_raw, 'end_time_raw(4i)', 'end_time_raw(5i)', :end_time_raw, :end_date, :end_time, :user_id, :time_zone, :contact, :id, :user_id, :high_school_id, :confirmed)
  end

  def visit_start
    startDate = DateTime.strptime(params[:visit][:start_date_raw]+" #{params[:visit]['start_time_raw(4i)']}:#{params[:visit]['start_time_raw(5i)']}:00 " + params[:visit]["time_zone"], "%m-%d-%Y %H:%M:%S %Z")
  end

  def visit_end
    endDate = DateTime.strptime(params[:visit][:end_date_raw]+" #{params[:visit]['end_time_raw(4i)']}:#{params[:visit]['end_time_raw(5i)']}:00 " + params[:visit]["time_zone"], "%m-%d-%Y %H:%M:%S %Z")
  end

  def visit_attrs(visit_params)
    visit_attrs = visit_params.clone
    visit_attrs[:start] = visit_start
    visit_attrs.delete :start_date_raw
    visit_attrs.delete 'start_time_raw(4i)'
    visit_attrs.delete 'start_time_raw(5i)'

    visit_attrs[:end] = visit_end
    visit_attrs.delete :end_date_raw
    visit_attrs.delete 'end_time_raw(4i)'
    visit_attrs.delete 'end_time_raw(5i)'
    
    return visit_attrs
  end 

  def visit_drag_attrs(visit_params)
    visit_drag_attrs = visit_params.clone
    visit_drag_attrs[:start] = DateTime.strptime(visit_drag_attrs[:start]).in_time_zone(visit_drag_attrs[:time_zone])
    visit_drag_attrs[:end] = DateTime.strptime(visit_drag_attrs[:end]).in_time_zone(visit_drag_attrs[:time_zone])
    visit_drag_attrs[:time_zone] = time_zone_converter_for_ics(visit_drag_attrs[:time_zone])
    return visit_drag_attrs

  end


end


