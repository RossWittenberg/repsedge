class Visit < ActiveRecord::Base

	require 'csv'
	belongs_to :user
	belongs_to :high_school

	include DateTimeAttribute

	date_time_attribute :start
	date_time_attribute :end

	validates_presence_of :title, 
		:location, 
		:start,
		:end,
		:time_zone

	validates :start, presence: true, date: { before_or_equal_to: :end, message: " time of an event cannot be after its end."} 

	validates :time_zone, 
	inclusion: { 
 		in: ActiveSupport::TimeZone.zones_map(&:name).keys, 
 		message: "is not a valid time zone"
	} 

	after_create { |visit| visit.addStartAndEndDateTimesOnCreate}

	def user_visit_start_dst_adjuster(user)
		if self.start.in_time_zone(user.time_zone).dst?
			(self.start - 1.hour).in_time_zone(user.time_zone)
		else
			self.start.in_time_zone(user.time_zone)
		end
	end	

	def user_visit_end_dst_adjuster(user)
		if self.end.in_time_zone(user.time_zone).dst?
			(self.end - 1.hour).in_time_zone(user.time_zone)
		else
			self.end.in_time_zone(user.time_zone)
		end
	end	

	def start_dst_adjuster
		if self.start.in_time_zone(self.time_zone).dst?
			(self.start - 1.hour).in_time_zone(self.time_zone)
		else
			self.start.in_time_zone(self.time_zone)
		end
	end

	def end_dst_adjuster
		if self.end.in_time_zone(self.time_zone).dst?
			(self.end - 1.hour).in_time_zone(self.time_zone)
		else
			self.end.in_time_zone(self.time_zone)
		end
	end

	def self.addStartAndEndDateTimesToAll
    Visit.find_each do |visit|
    	visit.update_attributes({
      	endDateTime: visit.end,
      	startDateTime: visit.start
      }) 
  	end
	end

	def addStartAndEndDateTimes(object)
		self.update_attributes(object)
		self.update_attributes({
    	endDateTime: self.end,
    	startDateTime: self.start
    })
    return true
	end

	def addStartAndEndDateTimesOnCreate
		self.update_attributes({
    	endDateTime: self.end,
    	startDateTime: self.start
    })
	end

	def textColor
		if self.category == "College Fair"
			return "#79c2df"
		elsif self.category =="Hotel"
			return "#363636"
		elsif self.category == "Reminder"
			return "#E66E00"
		elsif self.category == "High School Visit" && self.confirmed?
			return "#456f88" 
		elsif self.category == "High School Visit" && self.confirmed != true
			return "#B61F1F"
		else
			return "#615177"
		end
	end	

	def time_zone_mapping
    ActiveSupport::TimeZone::MAPPING[self.time_zone]
  end


end	