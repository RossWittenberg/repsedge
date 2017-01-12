class Admin::HighSchoolsController < ApplicationController

  include DeviseHelper
  include HighSchoolsHelper
  before_filter :authenticate_user! && :authenticate_admin


  def dashboard
    @user = current_user
    @accounts = Account.paginate(:page => params[:page], :per_page => 20)
    @users = User.where("role = 0")
  end

  def export 
    # @high_schools = HighSchool.select('name,county,address,city,state_abbreviation,zip_code,ceeb,hs_phone_num,guidance_phone_num,guidance_phone_num_ext,website,guidance_url,calendar_url,latitude,longitude,hs_type,classification,students_count,seniors_count,percent_female,percent_male,percent_asian_am,percent_african_am,percent_white,percent_hispanic_am,percent_other,reduced_lunch,four_year_school,magnet,charter,capstone,boarding,intl_bacc,sat_total,sat_math,sat_reading,sat_writing,act,median_income,religion,graduation_rate,repsedge_id')
    respond_to do |format|
      # @high_schools.to_csv
      format.csv { send_file "app/views/admin/high_schools/export.csv" }
    end
  end

  def import_template
    respond_to do |format|
      format.csv { send_data HighSchool.csvTemplate }
    end
  end

  def import_for_new
    if params[:file]
      if params[:file].content_type == "text/csv"
        if HighSchool.import_for_new(params[:file])
          redirect_to dashboard_admin_high_schools_path, notice: "New High Schools have been successfully added."
        else
          redirect_to dashboard_admin_high_schools_path, notice: "Please ensure that the file you have selected is properly formatted and try again. TIP: Download CSV Template below."
        end  
      else
        redirect_to dashboard_admin_high_schools_path, notice: "Please ensure that the file you have selected in the proper format (.csv) and try again."
      end
    else
      @user = current_user
      @accounts = Account.paginate(:page => params[:page], :per_page => 20)
      @users = User.where("role = 0")
      redirect_to dashboard_admin_high_schools_path, notice: "You must select a file to upload."
    end
  end

  # def import_for_update
  #   if params[:file] 
  #     HighSchool.import_for_update(params[:file])
  #     redirect_to dashboard_admin_high_schools_path, notice: "High Schools have been successfully updated."
  #   else
  #     render dashboard_admin_high_schools_path, notice: "You must select a to upload."
  #   end
  # end

  def search
    @states = State::ALL_STATES
  end

  def show
		@high_school = HighSchool.find(params[:id])
 	end	

 	def new
    @high_school = HighSchool.new
    @user = current_user
    @states = State::ALL_STATES
	end

	def edit
  	@high_school = HighSchool.find(params[:id])
    @states = State::ALL_STATES
	end

	def create    
    @high_school = HighSchool.new(high_school_attrs(high_school_params))
    if @high_school.save
      @high_school.update_attributes({state_abbreviation: @high_school.state.abbreviation})
      redirect_to dashboard_admin_high_schools_path, notice: "#{@high_school.name} was successfully created."
    else
      @user = current_user
      @states = State::ALL_STATES
      render action: "new", notice: @high_school.errors.full_messages
    end
	end

	def update
    @high_school = HighSchool.find(params[:id])
    @states = State::ALL_STATES
    @high_school.update(high_school_attrs(high_school_params))
    if @high_school.save
      @high_school.update_attributes({state_abbreviation: @high_school.state.abbreviation})
      redirect_to dashboard_admin_high_schools_path, notice: "#{@high_school.name} was successfully updated."
    else
      render action: "edit", notice: @high_school.errors.full_messages
    end
	end

	def destroy
    @user = current_user
    @accounts = Account.paginate(:page => params[:page], :per_page => 20)
    @users = User.where("role = 0")
    @high_school = HighSchool.find(params[:id])
    if @high_school.destroy
      render action: "dashboard", notice: "#{@high_school.name} was successfully deleted."
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

	def high_school_params
	  params.permit( :utf8, :_method, :authenticity_token, :commit, :id, :state, :county, high_school: [ :id, :name, :ceeb, :city, :state, :county, :address, :zip_code, :latitude, :longitude, :hs_phone_num, :guidance_phone_num, :website, :calendar_url, :hs_type, :classification, :religion, :address, :students_count, :seniors_count, :percent_male, :percent_female, :percent_asian_am, :percent_african_am, :percent_white, :percent_hispanic_am, :percent_other, :reduced_lunch, :four_year_school, :magnet, :charter, :capstone, :intl_bacc, :boarding, :sat_total, :sat_math, :sat_reading, :sat_writing, :act, :median_income, :created_at, :updated_at, :religion, :graduation_rate, :guidance_url, :state_id, :guidance_phone_num_ext, :repsedge_id ])
  end

  def high_school_attrs(high_school_params)
    high_school_attrs = high_school_params.clone
    high_school_attrs[:high_school][:state_id] = (State.find_by(abbreviation: high_school_params[:state])).id
    high_school_attrs[:high_school][:county] = high_school_params[:county]
    high_school_attrs[:high_school][:repsedge_id] = HighSchool.last.repsedge_id + 1
    return high_school_attrs[:high_school]
  end
end