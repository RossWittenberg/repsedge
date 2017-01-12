class Account < ActiveRecord::Base
	belongs_to :user

	validates_presence_of  :billing_street_address_line_1,
	:billing_city, 
	:billing_zip_code,
	:billing_state

	before_create :create_unique_order_num

	def create_unique_order_num
	  begin
	    self.order_num = SecureRandom.hex(5)
	  end while self.class.exists?(:order_num => order_num)
	end

	def formatted_street_address
		billing_street_address_line_2 != "" ? "#{self.billing_street_address_line_1.titleize}, #{self.billing_street_address_line_2.titleize}" : "#{self.billing_street_address_line_1.titleize}"
	end

	def formatted_mailing_address
		"#{self.billing_city.titleize}, #{self.billing_state} #{self.billing_zip_code}"
	end	

	def plan_id
		case self.plan_years
		when 1
			if self.plan_level == "Small Institution"
				return 101
			elsif self.plan_level == "Medium Institution"	
				return 102
			elsif self.plan_level == "Large Institution"	
				return 103
			end
		when 2
			if self.plan_level == "Small Institution"
				return 201
			elsif self.plan_level == "Medium Institution"	
				return 202
			elsif self.plan_level == "Large Institution"	
				return 203
			end	
		when 3
			if self.plan_level == "Small Institution"
				return 301
			elsif self.plan_level == "Medium Institution"	
				return 302
			elsif self.plan_level == "Large Institution"	
				return 303
			end	
		end	
	end

end
