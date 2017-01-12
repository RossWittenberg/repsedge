class ProspectiveStudentsController < ApplicationController

  include DeviseHelper
  before_filter :authenticate_user! 

  def dashboard

  end

  def export
  	@user = current_user
  	@prospective_students = @user.prospective_students.order(:last_name)
    respond_to do |format|
      format.csv { send_data @prospective_students.to_csv }
    end
  end

  def get_prospective_students_by_year
		@user = current_user
		if params[:high_school_id] 
			@high_school = HighSchool.find params[:high_school_id]
		elsif params[:high_school_name]
			# id = params[:high_school_name].reverse.slice(/[0-9]{6}/).reverse.to_i # local
			id = params[:high_school_name].reverse.slice(/[0-9]{5}/).reverse.to_i # production
			@high_school = HighSchool.find id
		end

		@year = params[:year].to_i

		if @high_school 
			@prospective_students = @user.prospective_students.where( {high_school: @high_school, year: @year }).order(created_at: :desc)
			redirect_to prospective_students_path(@user, year: @year, high_school_id: @high_school.id)
		else
			@prospective_students = @user.prospective_students.where( {high_school_id: nil, year: @year }).order(created_at: :desc)
			redirect_to prospective_students_path(@user, year: @year)
		end
  end	

  def get_prospective_students_by_id
		@user = current_user
  	@prospective_students = []
	  if params[:recipients]	
	  	params[:recipients].map do |recipient| 
	  		@prospective_students.push(ProspectiveStudent.find recipient )
	  	end
  		render json: { prospective_students: @prospective_students }
	  else
	  end	
  end

  def send_mail
		@user = current_user
  	@prospective_students = []
	  if params[:recipients].present? && params[:subject].present? && params[:content].present?
	  	params[:recipients].map do |recipient| 
	  		@prospective_students.push(ProspectiveStudent.find recipient )
	  	end
	  	@user.send_prospective_students_mail(@user, params[:subject], params[:content], @prospective_students)
			@prospective_student_message = "Your email has been sent to the selected email addresses."
	  else
			@prospective_student_message = "You must include a subject and body content to send emails from this form."
		end
	  render json: { prospective_student_message: @prospective_student_message }
  end

  def send_test_mail
		@user = current_user
  	@prospective_students = []
	  if params[:subject].present? && params[:content].present?
	  	@user.send_prospective_students_mail_test(@user, params[:subject], params[:content])
			@prospective_student_message = "A test email has been sent to your account."
	  else
			@prospective_student_message = "You must include a subject and body content to send emails from this form."
		end
	  render json: { prospective_student_message: @prospective_student_message }
  end






  

	def index
		@user = current_user
		if params[:high_school_id] 
			@high_school = HighSchool.find params[:high_school_id]
		elsif params[:high_school_name]
		# id = params[:high_school_name].reverse.slice(/[0-9]{6}/).reverse.to_i # local
			id = params[:high_school_name].reverse.slice(/[0-9]{5}/).reverse.to_i # production
			@high_school = HighSchool.find id
		end

		if params[:year]
			@year = params[:year].to_i
		else	
			@year = Time.now.year + 1
		end		
		
		if @high_school 
			@prospective_students = @user.prospective_students.where( {high_school: @high_school, year: @year }).order(last_name: :desc)
		else
			@prospective_students = @user.prospective_students.where( {high_school_id: nil, year: @year }).order(created_at: :desc)
		end

	end

	def new
		@user = current_user
		@prospective_student = ProspectiveStudent.new
		@high_school = HighSchool.find params[:high_school_id] if params[:high_school_id]
		@states = State::ALL_STATES
		@year = Time.now.year
		@majors = ProspectiveStudent.majors
	end

	def create 

		@user = current_user
		@high_school = HighSchool.find params[:prospective_student][:high_school_id] if params[:prospective_student] && params[:prospective_student][:high_school_id].present?
		@prospective_student = ProspectiveStudent.new(prospective_student_attrs(prospective_student_params))
		@states = State::ALL_STATES
		@majors = ProspectiveStudent.majors

		if prospective_student_params[:institution_id].present?
			@institution = Institution.find prospective_student_params[:institution_id]
			@prospective_student.institution = @institution
			@prospective_student.institution.save
		end

		if @prospective_student.save
			@year = @prospective_student.year
			@prospective_student.update_attributes({user_id: @user.id})
			if @high_school
				@prospective_student.high_school.save
				flash[:prospective_student_success] = "#{@prospective_student.first_name} #{@prospective_student.last_name} was successfully added."
				@prospective_student = ProspectiveStudent.new
				# redirect_to new_prospective_student_path(high_school_id: @high_school.id, year: @year)
				redirect_to new_prospective_student_path
			else
				@institution = nil
				flash.now[:prospective_student_success] = "#{@prospective_student.first_name} #{@prospective_student.last_name} was successfully added."
				@prospective_student = ProspectiveStudent.new	
				render "prospective_students/new"
			end
		else
			# @institution = nil
			# @high_school = nil
			@year = Time.now.year
			flash.now[:prospective_student_errors] = @prospective_student.errors.full_messages
			render "prospective_students/new"
		end
	end

	def edit
		@user = current_user
		@prospective_student = ProspectiveStudent.find params[:id]
		@high_school = @prospective_student.high_school unless @prospective_student.high_school_id == nil
		@institution = @prospective_student.institution unless @prospective_student.institution_id == nil
		@states = State::ALL_STATES
		@year = Time.now.year
		@majors = ProspectiveStudent.majors
	end

	def update
		@user = current_user
		@prospective_student = ProspectiveStudent.find params[:id]
		@states = State::ALL_STATES
		@year = Time.now.year
		if params[:prospective_student][:high_school_id]
			@prospective_student.update_attributes({high_school_id: params[:prospective_student][:high_school_id] })
		end

		if params[:prospective_student][:institution_id]
			@prospective_student.update_attributes({institution_id: params[:prospective_student][:institution_id] })
		end

		@institution = @prospective_student.institution unless @prospective_student.institution_id.blank?
		@high_school = @prospective_student.high_school unless @prospective_student.high_school_id.blank?

		if @prospective_student.update(prospective_student_attrs(prospective_student_params)) && @prospective_student.save
			if @prospective_student.high_school_id != nil
				flash[:prospective_student_success] =  "#{@prospective_student.first_name} #{@prospective_student.last_name} was successfully updated."
				redirect_to prospective_students_path(high_school_id: @high_school.id, year: @prospective_student.year)
			else
				flash[:prospective_student_success] = "#{@prospective_student.first_name} #{@prospective_student.last_name} was successfully updated."
				redirect_to prospective_students_path(year: @prospective_student.year)
			end
		else 
			flash.now[:prospective_student_errors] = "Please fill out all required fields."
			render :edit
		end
	end

	def destroy
		@user = current_user
		@prospective_student = ProspectiveStudent.find params[:id]
		@high_school = @prospective_student.high_school
		flash[:prospective_student_success] = "#{@prospective_student.first_name} #{@prospective_student.last_name} has been deleted."
		@prospective_student.destroy
		if @high_school
			redirect_to prospective_students_path(high_school_id: @high_school.id)
		else
			redirect_to prospective_students_path
		end
	end

	private

	def prospective_student_params
	  params.require(:prospective_student).permit(:first_name, :middle_name, :last_name, 'birthday(1i)', 'birthday(2i)', 'birthday(3i)', :gender, :street_address, :city, :state, :zip_code, :email, :phone_num, :high_school_id, :year, :user_id, :enrollment_type, :institution_id, :intended_major, :term)
  end

  def prospective_student_birthday
  	birthdayDate = DateTime.new(params[:prospective_student]['birthday(1i)'].to_i, params[:prospective_student]['birthday(2i)'].to_i, params[:prospective_student]['birthday(3i)'].to_i )
  end

  def prospective_student_attrs(prospective_student_params)
    prospective_student_attrs = prospective_student_params.clone
    prospective_student_attrs[:birthday] = prospective_student_birthday
    prospective_student_attrs.delete 'birthday(1i)'
    prospective_student_attrs.delete 'birthday(2i)'
    prospective_student_attrs.delete 'birthday(3i)'
    prospective_student_attrs.delete :user_id
    prospective_student_attrs[:year] = prospective_student_attrs[:year].to_i 
    return prospective_student_attrs
  end 

end