class VisitSerializer < ActiveModel::Serializer
	attributes :title, 
						 :start,
						 :end,
						 :category,
						 :location, 
						 :time_zone,
						 :user_id,
						 :high_school_id,
						 :phone_num,
						 :high_school_name,
						 :user_time_zone,
						 :id,
						 :confirmed
	def start
		if object.start.in_time_zone(object.time_zone).dst?
			(object.start - 1.hour).in_time_zone(object.time_zone)
		else
			object.start.in_time_zone(object.time_zone)
		end
	end

	def phone_num
		phone_num = "N/A"
		if object.high_school
			user = object.user
			phone_num = user.preferred_phones.includes(:high_school).where("high_school_id = #{object.high_school.id}").first || object.high_school.hs_phone_num
		end
		return phone_num
	end

	def high_school_name
		if object.high_school
			object.high_school.name
		end
	end

	def end
		if object.end.in_time_zone(object.time_zone).dst?
			(object.end - 1.hour).in_time_zone(object.time_zone)
		else
			object.end.in_time_zone(object.time_zone)
		end
	end	

	def time_zone
		ActiveSupport::TimeZone::MAPPING[object.time_zone]
	end		

	def user_time_zone
		object.user.time_zone
	end

	def confirmed
		object.confirmed
	end

end

