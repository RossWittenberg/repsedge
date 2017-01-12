module HighSchoolsHelper 		

	def convertRangeStringToRangeObject(string)
		rangeArray = string.split('..').map { |e| e.to_i }
		range = Range.new(rangeArray[0], rangeArray[1])
		return range
	end	

	def genderConverter(string)
		if string == "All Male"
			return 100
		elsif string == "All Female"
			return 0
		else
			return (0..100)	
		end			
	end	

	def gradRateConverter
		self.graduation_rate == 0.0 ? "N/A" : "#{self.graduation_rate.round}%"
	end	

	def incomeRounder(string)
		if string.blank? || string == "not available" || string == "0"
			return "N/A"
		elsif string.length < 4
			return string
		elsif string.length == 4
			return string[0..1].insert(1, ".")+"k"
		else
			return string.chop.chop.chop + "k"
		end
	end	

	def generateResultsString(high_school_params)	
		resultsStringArray = []
		if high_school_params[:hs_type] && high_school_params[:hs_type] != "ALL"
			resultsStringArray.push("Type")
		end
		
		if high_school_params[:classification] && high_school_params[:classification] != "ALL"
			resultsStringArray.push("Classification")
		end

		if high_school_params[:capstone] && high_school_params[:capstone] != "false"
			resultsStringArray.push("Capstone")
		end	

		if high_school_params[:intl_bacc] && high_school_params[:intl_bacc] != "false"
			resultsStringArray.push("Int'l Bacc")
		end	

		if high_school_params[:boarding] && high_school_params[:boarding] != "false"
			resultsStringArray.push("Boarding")
		end	

		if high_school_params[:magnet] && high_school_params[:magnet] != "false"
			resultsStringArray.push("Magnet")
		end	

		if high_school_params[:charter] && high_school_params[:charter] != "false"
			resultsStringArray.push("Charter")
		end	

		if high_school_params[:religion] && high_school_params[:religion] != "ALL"
			resultsStringArray.push("Religion")
		end

		if high_school_params[:students_count] && high_school_params[:students_count] != (0..50000)
			resultsStringArray.push("Number of Students")
		end

		if high_school_params[:percent_male] && high_school_params[:percent_male] != "ALL"
			resultsStringArray.push("Gender")
		end	

		if high_school_params[:percent_white] && high_school_params[:percent_white] != (0..100)
			resultsStringArray.push("Diversity")
		end

		if high_school_params[:graduation_rate] && high_school_params[:graduation_rate] != (0..100)
			resultsStringArray.push("Graduation Rate")
		end

		if high_school_params[:median_income] && high_school_params[:median_income] != (0..9999999)
			resultsStringArray.push("Income")
		end

		if high_school_params[:reduced_lunch] && high_school_params[:reduced_lunch] != (0..100)
			resultsStringArray.push("% Free/Reduced Lunch")
		end

		if high_school_params[:act] && high_school_params[:act] != (0..36)
			resultsStringArray.push("ACT")
		end

		if high_school_params[:sat_total] && high_school_params[:sat_total] != (0..2400)
			resultsStringArray.push("SAT")
		end

		resultsString = resultsStringArray.join(", ")
		return resultsString
	end

	def convertDiversity( int )
		if int.blank?
			return "no data"
		else		
			if int > 60
				return "Less Diverse"
			elsif (int < 60) && (int > 20)
				return "Somewhat Diverse"
			else
				return "Diverse"
			end	
		end	
	end	

	def all_features_blank?
        return true unless magnet || charter || capstone || intl_bacc || boarding
    end
	
end	