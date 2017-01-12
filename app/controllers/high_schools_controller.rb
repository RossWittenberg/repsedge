class HighSchoolsController < ApplicationController
  
  before_filter :authenticate_user! 
	
	include HighSchoolsHelper

	def search
		@states = State::ALL_STATES
	end	

	def error
		@high_school = HighSchool.find(params[:high_school_id])
		@user = current_user
		@error = params[:error]
		@user.send_profile_error(@high_school, @error)
		flash[:error_thank_you] = "Thank you for your feedback."
		redirect_to high_school_path @high_school
	end

	def missing
		@user = current_user
		@missing = params[:error]
		@user.send_missing_school(@missing)
		flash[:missing] = "Thank you for your feedback."
		redirect_to search_high_schools_path
	end

	def show
		@year = Time.now.year

		@user =  current_user
		@high_school = HighSchool.find(params[:id])

		@preferred_phones = @user.preferred_phones.where("high_school_id = #{@high_school.id}")
		@preferred_phone = @user.preferred_phones.new

		@preferred_guidance_websites = @user.preferred_guidance_websites.where("high_school_id = #{@high_school.id}")
		@preferred_guidance_website = @user.preferred_guidance_websites.new

		@preferred_calendars = @user.preferred_calendars.where("high_school_id = #{@high_school.id}")
		@preferred_calendar = @user.preferred_calendars.new

		@preferred_emails = @user.preferred_emails.where("high_school_id = #{@high_school.id}")
		@preferred_email = @user.preferred_emails.new
		
		@notes = @user.notes.all.where("high_school_id = #{@high_school.id}").order(created_at: :desc).limit(5).reverse
		@note = @user.notes.new

		if @high_school.geocoded?
			@nearbys = HighSchool.near(@high_school, 5, :order => "distance").limit(11)
		end	

 	end	

 	def index
 		@saved_search = SavedSearch.new
		@states = State::ALL_STATES
		# consider unnest
		if params[:state]
			params[:high_school]["state"] = params[:state]
		end
		if params[:county]
			params[:high_school]["county"] = params[:county]
		end	
		if params[:city_query]
			params[:high_school]["city_query"] = params[:city_query]
		end
		if params[:name_or_ceeb_query]
			params[:high_school]["name_or_ceeb_query"] = params[:name_or_ceeb_query]
		end

		if params[:high_school]["act"]
			params[:high_school]["act"] = convertRangeStringToRangeObject(params[:high_school]["act"])
		end
		if params[:high_school]["sat_total"] 
			params[:high_school]["sat_total"] = convertRangeStringToRangeObject(params[:high_school]["sat_total"])
		end
		if params[:high_school]["capstone"] && (params[:high_school]["capstone"] == "true" )
			params[:high_school]["capstone"] = true
		end	
		if params[:high_school]["intl_bacc"] && (params[:high_school]["intl_bacc"] == "true" )
			params[:high_school]["intl_bacc"] = true
		end	
		if params[:high_school]["boarding"] && (params[:high_school]["boarding"] == "true" )
			params[:high_school]["boarding"] = true
		end	
		if params[:high_school]["charter"] && (params[:high_school]["charter"] == "true" )
			params[:high_school]["charter"] = true
		end	
		if params[:high_school]["magnet"] && (params[:high_school]["magnet"] == "true" )
			params[:high_school]["magnet"] = true
		end	
		if params[:high_school]["hs_type"]
			params[:high_school]["hs_type"] = params[:high_school]["hs_type"]
		end	
		if params[:high_school]["classification"]
			params[:high_school]["classification"] = params[:high_school]["classification"]
		end
		if params[:high_school]["students_count"]
			params[:high_school]["students_count"] = convertRangeStringToRangeObject(params[:high_school]["students_count"])
		end	
		if params[:high_school]["percent_male"]
			params[:high_school]["percent_male"] = params[:high_school]["percent_male"]
		end	
		if params[:high_school]["four_year_school"]
			params[:high_school]["four_year_school"] = convertRangeStringToRangeObject(params[:high_school]["four_year_school"])
		end
		if params[:high_school]["percent_white"]
			params[:high_school]["percent_white"] = convertRangeStringToRangeObject(params[:high_school]["percent_white"])
		end
		if params[:high_school]["median_income"]
			params[:high_school]["median_income"] = convertRangeStringToRangeObject(params[:high_school]["median_income"])
		end
		if params[:high_school]["reduced_lunch"]
			params[:high_school]["reduced_lunch"] = convertRangeStringToRangeObject(params[:high_school]["reduced_lunch"])
		end
		if params[:high_school]["graduation_rate"]
			params[:high_school]["graduation_rate"] = convertRangeStringToRangeObject(params[:high_school]["graduation_rate"])
		end
		
		search = HighSchool.searchForHighSchools(params[:high_school])
		@total_results = search.total
 		
 		if user_signed_in?
			@user = User.find(current_user.id)
			@saved_searches = @user.saved_searches
		end
		if search.results.blank?
	  	flash.now[:search] = "The search parameters you selected yielded no results. Please modify your search and try again."
		elsif search.results.count > 1000
	  	flash[:search] = "The search parameters you selected yielded too many results. Please refine your search and try again."
			redirect_to search_high_schools_path
		else
			@high_schools = search.results
			@county = params[:county]
			@response = { user: @user, 
									 county: @county,
									 saved_searches: @saved_searches, 
									 high_schools: @high_schools, 
									 total_results: @total_results }
	  end  
	end 

 	def name_or_ceeb_query_auto_complete
		search = Sunspot.search(HighSchool) do 
			fulltext params[:name_or_ceeb_query] do	
				fields(:ceeb)
				fields(:name)
			end	
		end 
		bucket = [] 
		search.results.each { |high_school| bucket.push( { user_id: current_user.id, 
																											 name: high_school.name, 
																											 city: high_school.city,
																											 state: high_school.state,
																											 ceeb: high_school.modify_ceeb,
																											 id: high_school.id	} ) }
		if bucket.count > 1000
			return false
		else
			render json: bucket.flatten
		end
	end


	def city_auto_complete
		search = Sunspot.search(HighSchool) do 
			with :state_abbreviation, params[:state] unless params[:state].blank?	
			fulltext params[:city_query] do	
				fields(:city)
			end	
		end 
		bucket = [] 
		uniq_cities = search.results.map { |school| school.city }.uniq
		sorted_cities = uniq_cities.sort_by { |city| city }
		sorted_cities.each { |city| bucket.push( city ) }
		render json: bucket.flatten
	end

	def get_counties
		high_schools = Sunspot.search(HighSchool) do
			all_of do
			  with :state_abbreviation, params[:state] unless params[:state].blank?
			end
		end

		@county = params[:county]
		uniq_high_schools_by_counties = high_schools.results.uniq { |high_school| high_school.county }

		@counties = uniq_high_schools_by_counties.map { |high_school| high_school.county  }

		@counties.reject! { |c| c.blank? }

		@counties.sort!

		response = { county: @county, counties: @counties}
		render json: response
	end	

	def high_school
		id = params[:high_school].reverse.slice(/[0-9]{5}/).reverse.to_i # production
		# id = params[:high_school].reverse.slice(/[0-9]{6}/).reverse.to_i # local
		@high_school = HighSchool.find id
		render json: @high_school
	end

	private

	def high_school_params
	  params.require(:high_school).permit(:name, :county, :address, :city, :state, :zip_code, :ceeb, :hs_phone_num, :guidance_phone_num, :website, :calendar_url, :latitude, :longitude, :hs_type, :classification,:students_count,:total_seniors,:percent_male,:percent_female,:percent_asian_am,:percent_african_am,:percent_white,:percent_hispanic_am,:percent_other,:reduced_lunch,:four_year_school,:magnet,:charter, :capstone, :intl_bacc, :boarding,:sat_total, :sat_math,:sat_reading, :sat_writing, :act, :median_income, :religion, :graduation_rate)
  end
end






