class State < ActiveRecord::Base

	has_many :high_schools 

	def self.options_for_select
  	states = self.order(:name).map { |e| e.name  }
		return states.uniq
  end
  
  ALL_STATES = self.all

end