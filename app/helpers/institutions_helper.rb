module InstitutionsHelper 		
	def institutions_for_select
	  Institution.all.collect { |i| [i.name, i.id] }
	end


end

