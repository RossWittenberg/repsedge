class PreferredGuidanceWebsite < ActiveRecord::Base
	belongs_to :high_school
	belongs_to :user

	before_validation :add_url_protocol, on: [:create, :update]

  validates :url, format: { with: /(\S+\.(com|net|org|edu|gov|us|info|nyc)(\/\S+)?)/, message: "Must be a valid url. " }
	
	def add_url_protocol
	  unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
	    self.url = "http://#{self.url}"
	  end
	end

end
