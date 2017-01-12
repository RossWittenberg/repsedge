class ProspectiveStudent < ActiveRecord::Base
  belongs_to :high_school
  belongs_to :institution
  belongs_to :user

	validates_presence_of :first_name,
                        :last_name,
                        :birthday,
                        :gender,
                        :street_address,
                        :city,
                        :state,
                        :zip_code,
                        :phone_num,
                        :email,
                        :intended_major,
                        :enrollment_type,
                        :year

  validates_email_format_of :email, :generate_message => true

  validates_presence_of :term, unless: -> (prospective_student){prospective_student.enrollment_type == "High School"}                      
  
  # validates_presence_of :cell_phone_num, unless: ->(prospective_student){prospective_student.home_phone_num.present?}, message: "or home phone must be provided."
  # validates_presence_of :home_phone_num, unless: ->(prospective_student){prospective_student.cell_phone_num.present?}, message: "or cell phone must be provided."

  validates_presence_of :high_school_id, unless: ->(prospective_student){prospective_student.institution_id.present? }, message: "or institution must be selected."
  validates_presence_of :institution_id, unless: ->(prospective_student){prospective_student.high_school_id.present? }, message: "or a high school must be selected."

  validates_inclusion_of :enrollment_type, in: ["High School", "Transfer"]
  validates_inclusion_of :term, in: ["Spring", "Summer", "Fall", nil]
  validates_inclusion_of :gender, in: ["Male", "Female"]

  validates :phone_num, format: { with: /\A([01][- .()])?(\(\d{3}\)|\d{3})[- .]*?\d{3}[- .]*\d{4}\Z/, message: "Must be a valid 10-digit phone number." }, :allow_blank => true
  # validates :cell_phone_num, format: { with: /\A([01][- .()])?(\(\d{3}\)|\d{3})[- .]*?\d{3}[- .]*\d{4}\Z/, message: "Must be a valid 10-digit phone number." }, :allow_blank => true
  # validates :home_phone_num, format: { with: /\A([01][- .()])?(\(\d{3}\)|\d{3})[- .]*?\d{3}[- .]*\d{4}\Z/, message: "Must be a valid 10-digit phone number." }, :allow_blank => true


  before_validation :set_enrollment_type

  def set_enrollment_type
    self.high_school_id.blank? ? self.enrollment_type = "Transfer" : self.enrollment_type = "High School"
  end

  def formatted_address
  	"#{self.street_address} #{self.city}, #{self.state} #{self.zip_code}"
  end

  def self.to_csv
    attributes = %w{first_name middle_name last_name birthday gender street_address city state zip_code email phone_num enrollment_type term year created_at intended_major institution high_school} 
    CSV.generate( { headers: true } ) do |csv|
      csv << attributes
      self.all.each do |prospective_student|
        csv << [prospective_student.first_name, prospective_student.middle_name, prospective_student.last_name, prospective_student.birthday, prospective_student.gender, prospective_student.street_address, prospective_student.city, prospective_student.state, prospective_student.zip_code, prospective_student.email, prospective_student.phone_num, prospective_student.enrollment_type, prospective_student.term, prospective_student.year, prospective_student.created_at, prospective_student.intended_major, (prospective_student.institution && prospective_student.institution.name || "N/A"), (prospective_student.high_school && prospective_student.high_school.name || "N/A")]
      end 
    end
  end

  def self.majors
    return ["Undecided","Accounting","Advertising","African American Studies","American/United States Studies","American Indian/Native American Studies","Ancient Studies","Animal Studies","Anthropology","Arabic Studies","Archeology","Arabic Studies","Architecture","Art History","Art Studio","Asian and Asian American Studies","Astronomy","Athletic Training","Automotive","Biblical Studies","Biochemistry","Biology","Business Administration","Chemistry","Chinese Studies","Classical Studies","Communicative Disorders","Communication and Media Arts","Computer Information Systems","Computer Programming and Gaming","Computer Science","Criminal Justice","Dance","Drama","East Asian Studies","Ecology","Economics","Education, Elementary","Education, Secondary","Engineering - General","Engineering -AeroSpace","Engineering - Bioengineering","Engineering- Civil","Engineering- Chemical","Engineering - Computer","Engineering - Electrical","Engineering - Industrial and Systems Science","Engineering - Mechanical","Engineering- Nuclear","English","Entrepreneurial Studies","Environmental Studies","Ethnic Studies","Family and Consumer Science","Fashion/Apparel Design","Fashion Merchandising","Film and Cinema Studies","Finance","Fine Arts","Forensic Science","Forestry","French Language and Literature","Genetics","Gender Studies","Geography","Geological Sciences","German Language and Literature","Graphic Design","Greek Studies","Hispanic Studies","History","Hospitality","Hotel Management","Human Development","Human Resource Management","Interior Design","International Business","Islamic Studies","Italian Studies","Japanese Studies","Journalism","Jewish/Judaic Studies","Kinesiology","Korean Studies","Labor Relations","Latin American and Caribbean Area Studies","Leadership","Legal Studies","Linguistics","Literature","Marine Biology","Management","Management Information Systems","Marketing","Mathematics","Medieval Studies","Music Education","Music History","Music Theory","Music Management","Musical Performance","Neuroscience","Nursing","Nutrition Science","Occupational Therapy","Oceanography","Pharmacy","Philosophy","Photography","Physics","Physical Therapy","Physician Assistant","Physiology","Political Science","Pre-Law","Pre-Medicine","Psychology","Public Health","Public Policy","Public Relations","Real Estate","Religious Studies","Russian Studies","Sociology","Social Work","Sports Management","Speech Communication","Statistics","Spanish Language and Literature","Theatre Arts","Women's Studies","Zoology","Other"]
  end

# ProspectiveStudent.all.each {|hs| hs.update_attributes({home_phone_num: nil, cell_phone_num: nil })} 

end