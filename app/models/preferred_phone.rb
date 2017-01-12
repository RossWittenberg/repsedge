class PreferredPhone < ActiveRecord::Base
	belongs_to :high_school
	belongs_to :user

	validates_presence_of :num, { message: "Can't be blank." }
  validates :num, format: { with: /\A([01][- .()])?(\(\d{3}\)|\d{3})[- .]*?\d{3}[- .]*\d{4}\Z/, message: "Must be a valid 10-digit phone number." }

  before_save :formatPhoneNumberForDB

  private

  def formatPhoneNumberForDB
    onlyNums = []
    self.num.gsub(/[0-9]/) { |match| onlyNums.push(match) }
    self.num = onlyNums.join("").insert(3, "-").insert(7, "-")
  end

end
