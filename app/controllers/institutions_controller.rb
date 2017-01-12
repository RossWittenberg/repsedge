class InstitutionsController < ApplicationController	
	
  # before_filter :authenticate_user!

	def institution_auto_complete
		search = Sunspot.search(Institution) do 
			with :state, params[:state] unless params[:state].blank?	
			fulltext params[:institution_query] do	
				fields(:name)
			end	
		end 
		bucket = [] 		
		uniq_institutions = search.results.map { |institution| institution.name }.uniq
		sorted_institutions = uniq_institutions.sort_by { |name| name }
		sorted_institutions.each { |name| bucket.push( name ) }
		render json: bucket.flatten
	end

	def institution
		@institution = Institution.find_by name: params[:institution]
		render json: @institution
	end

end	