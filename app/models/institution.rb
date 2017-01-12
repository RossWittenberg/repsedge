class Institution < ActiveRecord::Base
 	
	has_many :users, dependent: :destroy
  has_many :prospective_students, dependent: :destroy


	validates_presence_of :name, 
		:city, 
		:zip_code, 
		:enrollment 

	ALL_INSTITUTIONS = self.all

	searchable auto_index: true, auto_remove: true do
		text   :name
		string :state
	end	

	def plan_level
		self.enrollment < 5000 ? "Small Institution" : (self.enrollment > 5000 && self.enrollment < 15000 ? "Medium Institution" :  "Large Institution" )
	end	
	#########################
	#   ORIGINAL PRICING    #
	#########################
	# def plan_cost( years )
	# 	case years
	# 	when 1
	# 		if self.plan_level == "Small Institution"
	# 			return 2500
	# 		elsif self.plan_level == "Medium Institution"	
	# 			return 4500
	# 		elsif self.plan_level == "Large Institution"	
	# 			return 6375
	# 		end
	# 	when 2
	# 		if self.plan_level == "Small Institution"
	# 			return 3000
	# 		elsif self.plan_level == "Medium Institution"	
	# 			return 5400
	# 		elsif self.plan_level == "Large Institution"	
	# 			return 7650
	# 		end	
	# 	when 3
	# 		if self.plan_level == "Small Institution"
	# 			return 3500
	# 		elsif self.plan_level == "Medium Institution"	
	# 			return 6300
	# 		elsif self.plan_level == "Large Institution"	
	# 			return 8925
	# 		end				
	# 	end		
	# end

	def plan_cost( years )
		case years
		when 1
			if self.plan_level == "Small Institution"
				return 1500
			elsif self.plan_level == "Medium Institution"	
				return 1800
			elsif self.plan_level == "Large Institution"	
				return 200
			end
		when 2
			if self.plan_level == "Small Institution"
				return 2700
			elsif self.plan_level == "Medium Institution"	
				return 3240
			elsif self.plan_level == "Large Institution"	
				return 3600
			end	
		when 3
			if self.plan_level == "Small Institution"
				return 3825
			elsif self.plan_level == "Medium Institution"	
				return 4590
			elsif self.plan_level == "Large Institution"	
				return 5100
			end				
		end		
	end	

	def formatted_mailing_address
		formatted_mailing_address = "#{self.city.titleize}, #{self.state} #{self.zip_code}"
	end	

	def modified_zip_code
		self.zip_code.length == 4 ? "0" + self.zip_code : self.zip_code
	end

	def plan_years
		self.enrollment < 5000 ? self.small_institution : (self.enrollment > 5000 && self.enrollment < 15000 ? self.medium_institution	:  self.large_institution )
	end	

	def one_year_price
		self.enrollment < 5000 ? "1500" : (self.enrollment > 5000 && self.enrollment < 15000 ? "1800" :  "2000" )
	end

	#########################
	#   ORIGINAL PRICING    #
	#########################

	# def small_institution 
	# 	{ "1 year" => '2500',
	# 	"2 years (Save 10%)" => '4500',
	# 	"3 years (Save 15%)"=> '6375'}#,
	# 	#"4 years (Save 20%)"=> '8000',
	# 	#"5 years (Save 25%)"=> '9375' }
	# end	
	# def medium_institution 
	# 	{ "1 year" => '3000',
	# 	"2 years (Save 10%)" => '5400',
	# 	"3 years (Save 15%)"=> '7650'}#,
	# 	# "4 years (Save 20%)"=> '9600',
	# 	# "5 years (Save 25%)"=> '11250' }
	# end	
	# def large_institution 
	# 	{ "1 year" => '3500',
	# 	"2 years (Save 10%)" => '6300',
	# 	"3 years (Save 15%)"=> '8925'}#,
	# 	# "4 years (Save 20%)"=> '11200',
	# 	# "5 years (Save 25%)"=> '13125' }
	# end

	def small_institution 
		{ "1 year" => '1500',
		"2 years (Save 10%)" => '2700',
		"3 years (Save 15%)"=> '3825'}
	end	
	def medium_institution 
		{ "1 year" => '1800',
		"2 years (Save 10%)" => '3240',
		"3 years (Save 15%)"=> '4590'}
	end	
	def large_institution 
		{ "1 year" => '2000',
		"2 years (Save 10%)" => '3600',
		"3 years (Save 15%)"=> '5100'}
	end	

end
