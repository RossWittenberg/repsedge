class PreferredEmail < ActiveRecord::Base
	belongs_to :high_school
	belongs_to :user

  validates_email_format_of :address, { message: "Does not appear to be a valid email address." }
	validates_presence_of :address

end
