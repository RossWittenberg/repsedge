class Note < ActiveRecord::Base
	belongs_to :high_school
	belongs_to :user
	before_create :set_time_tag_to_now


	validates_presence_of :content



# Solr indexing
	searchable auto_index: true, auto_remove: true do
		integer :user, :stored => true do
      user.id
   	end
		text :high_school, :stored => true do
      high_school.name
   	end
		text :content, :stored => true
	end

	def self.searchNotes(keyword, user)
		search = Sunspot.search(self) do
			with(:user, user.id)
			fulltext keyword do
				highlight :content
				highlight :high_school
			end	
		end	
	end 

  def set_time_tag_to_now
    self.time_tag = Time.now unless self.time_tag.present?
  end


end
