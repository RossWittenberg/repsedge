desc "Sends weekly agenda to User"
task :send_weekly_agenda_email => :environment do
	if Time.now.sunday?  
	  agenda_recipients = User.where(weekly_agenda: true)
	  agenda_recipients.each do |user|
		  ApplicationMailer.weekly_agenda(user).deliver
		end 
	end	
end
