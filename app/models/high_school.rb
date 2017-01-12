class HighSchool < ActiveRecord::Base
	
	include HighSchoolsHelper

	geocoded_by :formatted_address

	# after_validation :geocode
	
  has_many :preferred_phones, dependent: :destroy
  has_many :preferred_guidance_websites, dependent: :destroy
  has_many :preferred_calendars, dependent: :destroy
  has_many :preferred_emails, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :prospective_students, dependent: :destroy

  belongs_to :state

  before_validation :modify_ceeb, on: [:create, :update]
	# before_validation :normalize, on: [:create, :update]
	before_validation :set_defaults_for_missing_data, on: [:create, :update]

	validates_presence_of :name, 
		:address, 
		:city,
		:county, 
		:zip_code, 
		:hs_type,
		:students_count,
		:latitude,
		:longitude 
	validates :name, length: { minimum: 2 }
  validates_inclusion_of :magnet,
		:charter, 
		:capstone, 
		:intl_bacc, 
		:boarding,
		in: [true, false]

	#########################################
	############### indexing ################
	#########################################...

	searchable auto_index: true, auto_remove: true do
		string   :state_abbreviation
		string   :county
		string   :classification
		string   :hs_type
		string   :name
		string   :religion
    integer  :median_income
		integer  :zip_code
		integer  :students_count
    integer  :sat_total
    float    :graduation_rate
		float    :percent_male
		float    :percent_white
		float    :act
		float    :reduced_lunch	
    float    :four_year_school	
		boolean  :magnet
    boolean  :charter
    boolean  :capstone
    boolean  :intl_bacc
    boolean  :boarding
		text     :name
		text     :city
		text     :ceeb
	end

	###########################################
	###########################################

	def set_defaults_for_missing_data
		if self.sat_total.blank?
    	self.sat_total = 0
    end
    if self.act.blank?
    	self.act = 0
    end
    if self.graduation_rate.blank?
    	self.graduation_rate = 0
    end
    if self.students_count.blank?
    	self.students_count = 0
    end
  end  

  def geocode_by_address
  	self.geocode
  end


# HighSchool.all.each { |hs| hs.update_attributes({ceeb: hs.modify_ceeb}) }

	# def importData
	#   csv_file_path = 'db/seeds/schools.csv'
	# 	CSV.foreach(csv_file_path, :headers => true) do |row|
	# 		hs = find_by(ceeb: row["ceeb"]) || new	
	# 	  hs.update row.to_hash
	# 	  hs.state = State.find_by(abbreviation: hs.state_abbreviation)
	# 	  hs.save!
	# 	end  
	# end


  # def normalize
  # 	# psPattern = /([p][s])|([p][.][s].)/i
  #   self.name = self.name.downcase.titleize unless self.name.match psPattern
  #   self.hs_type = self.hs_type.downcase.titleize
  # end

	def cityStateZipCounty
		"#{self.city}, #{self.state.abbreviation} #{self.zip_code}, #{self.county}"
	end		

	def formatted_address
		"#{self.address} #{self.city}, #{self.state.abbreviation} #{self.zip_code}"
	end

	def modify_ceeb
		if self.ceeb
			self.ceeb.to_s.length == 4 ? ("00" + self.ceeb.to_s) : ( self.ceeb.to_s.length == 5 ) ? ( "0" + self.ceeb.to_s ) : self.ceeb.to_s
		end	
	end

	def self.to_csv
		attributes = %w{name county address city state_abbreviation zip_code ceeb hs_phone_num guidance_phone_num website calendar_url latitude longitude hs_type classification students_count seniors_count percent_male percent_female percent_asian_am percent_african_am percent_white percent_hispanic_am percent_other reduced_lunch four_year_school magnet charter capstone intl_bacc boarding sat_total sat_math sat_reading sat_writing act median_income religion graduation_rate guidance_url guidance_phone_num_ext repsedge_id}
		file = "app/views/admin/high_schools/export.csv"
		CSV.open( file, "w", { headers: true } ) do |csv|
			csv << attributes
			self.all.each do |high_school|
				csv << high_school.attributes.values_at(*attributes)
			end	
		end
		return 
	end

	def self.csvTemplate
		attributes = %w{name,county,address,city,state_abbreviation,zip_code,ceeb,hs_phone_num,guidance_phone_num,guidance_phone_num_ext,website,guidance_url,calendar_url,latitude,longitude,hs_type,classification,students_count,seniors_count,percent_female,percent_male,percent_asian_am,percent_african_am,percent_white,percent_hispanic_am,percent_other,reduced_lunch,four_year_school,magnet,charter,capstone,boarding,intl_bacc,sat_total,sat_math,sat_reading,sat_writing,act,median_income,religion,graduation_rate}		
		CSV.generate(headers: true) do |csv|
			csv << attributes
		end
	end

	# def self.updateFromCSV
	# 	csv_file_path = 'db/seeds/import-test.csv'
	# 	CSV.foreach(csv_file_path, headers: true, encoding: "windows-1251:utf-8" ) do |row|
	# 	  hs = self.find_by(repsedge_id: row["repsedge_id"].to_i) || self.new
	# 	  hs.attributes = row.to_hash
	# 	  hs.state = State.find_by(abbreviation: hs.state_abbreviation)
	# 	  hs.save!
	# 	end
	# end

	def self.import_for_new(file)
		CSV.foreach(file.path, headers: true, encoding: "windows-1251:utf-8" ) do |row|
		  hs = self.new
		  hs.repsedge_id = HighSchool.last.repsedge_id + 1
		  hs.attributes = row.to_hash
		  hs.state = State.find_by(abbreviation: hs.state_abbreviation)
		  hs.save!
		end
	end

	def self.import_for_update(file)
		CSV.foreach(file.path, headers: true, encoding: "windows-1251:utf-8" ) do |row|
		  hs = self.find_by(repsedge_id: row["repsedge_id"])
		  hs.update_attributes(row.to_hash)
		end
	end

	def self.addRepsEdgeIds
		csv_file_path = 'db/seeds/schools.csv'
		rows = CSV.read(csv_file_path, headers: true, encoding: "windows-1251:utf-8" )
		self.all.each_with_index do |hs, i|
			hs.repsedge_id = rows[i]["repsedge_id"].to_i
			hs.save!
		end	  
	end

	def self.searchForHighSchools(params)
		search = Sunspot.search(self) do
		  all_of do
		    with :state_abbreviation, params[:state] unless params[:state].blank?
		    with(:county).starting_with(params[:county]) unless params[:county].blank?
		  	with :capstone, params[:capstone] if params[:capstone] == true 
		  	with :intl_bacc, params[:intl_bacc] if params[:intl_bacc] == true 
		  	with :boarding, params[:boarding] if params[:boarding] == true 
		  	with :charter, params[:charter] if params[:charter] == true 
		  	with :magnet, params[:magnet] if params[:magnet] == true 
		  	with :sat_total, params[:sat_total] unless params[:sat_total].blank? || params[:sat_total] ==  (0..2400)
		  	with :act, params[:act] unless params[:act].blank? || params[:act] == (0..36)
		    with :hs_type, params[:hs_type] unless params[:hs_type].blank? || params[:hs_type] == "ALL"
		    with :classification, params[:classification] unless params[:classification].blank? || params[:classification] == "ALL"
		    with :religion, params[:religion] unless params[:religion].blank? || params[:religion] == "ALL"
		    with :students_count, params[:students_count] unless params[:students_count].blank? || params[:students_count] == (0..50000)
		    with :percent_male, params[:percent_male] unless params[:percent_male].blank? || params[:percent_male] == "ALL"
		    with :four_year_school, params[:four_year_school] unless params[:four_year_school].blank? || params[:four_year_school] == "ALL"
		    with :percent_white, params[:percent_white] unless params[:percent_white].blank? || params[:percent_white] == (0..100)
		    with :median_income, params[:median_income] unless params[:median_income].blank? || params[:median_income] == (0..9999999)
		    with :reduced_lunch, params[:reduced_lunch] unless params[:reduced_lunch].blank? || params[:reduced_lunch] == (0..100)
		    with :graduation_rate, params[:graduation_rate] unless params[:graduation_rate].blank? || params[:graduation_rate] == (0..100)
		  end  

	  	fulltext params[:city_query] unless params[:city_query].blank?
	  	fulltext params[:name_or_ceeb_query] unless params[:name_or_ceeb_query].blank?
	  	order_by(:name, :asc)
		end
		return search
	end
end	


