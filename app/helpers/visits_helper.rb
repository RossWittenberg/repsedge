module VisitsHelper 	

	def time_zone_converter_for_ics(tz_string_from_form)
		ics_tz = Hash.new
		case tz_string_from_form
		when "Pacific/Honolulu"
			ics_tz = "Hawaii" 
		when "America/Juneau"	
			ics_tz = "Alaska" 
		when "America/Los_Angeles"
			ics_tz = "Pacific Time (US & Canada)" 
		when "America/Phoenix"	
			ics_tz = "Arizona" 
		when "America/Denver"			
			ics_tz = "Mountain Time (US & Canada)" 
		when "America/Chicago"
			ics_tz = "Central Time (US & Canada)" 
		when "America/Indianapolis"
			ics_tz = "Indiana (US & Canada)" 
		when "America/New_York"
			ics_tz = "Eastern Time (US & Canada)" 
		end
		return ics_tz	
	end

	def time_zone_converter(time_zone_string)
		case time_zone_string
		when "Hawaii" 
			return "Pacific/Honolulu"
		when "Alaska" 
			return "America/Juneau"	
		when "Pacific Time (US & Canada)" 
			return "America/Los_Angeles"
		when "Arizona" 
			return "America/Phoenix"	
		when "Mountain Time (US & Canada)" 
			return "America/Denver"			
		when "Central Time (US & Canada)" 
			return "America/Chicago"
		when "Indiana (US & Canada)" 
			return "America/Indianapolis"
		when "Eastern Time (US & Canada)" 
			return "America/New_York"
		end
	end	

end
