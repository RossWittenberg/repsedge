class ApplicationMailer < MandrillMailer::TemplateMailer

	include ActionView::Helpers::NumberHelper
	include DeviseHelper

	default from: "info@repsedge.com", from_name: "RepsEdge"

	def self.account_activation(user)
		if user.role > User::ROLE_REP
			user.confirm!
			user.save!
		end
		mandrill_mail(
			template: "account-activation",
			subject: "New Account: #{user.first_name} #{user.last_name}",
			to: [ { email: "info@repsedge.com", name: "RepsEdge" }, 
						{email: user.email, name: "#{user.first_name} #{user.last_name}" } ],
			vars: {
				"FIRST_NAME" => user.first_name,
				"LAST_NAME" => user.last_name,
				"PLAN_LEVEL" => user.institution.plan_level,
				"PLAN_YEARS" => user.account.plan_years, 
				"PLAN_PRICE" => number_to_currency(user.account.plan_price),
				"INSTITUTION" => user.institution.name,
				"PAYMENT_TYPE" => user.account.payment_type, 
				"INSTITUTION_ADDRESS_PART_1" => user.institution.street_address,
				"INSTITUTION_ADDRESS_PART_2" => user.institution.formatted_mailing_address,
				"BILLING_ADDRESS_PART_1" => user.account.formatted_street_address,
				"BILLING_ADDRESS_PART_2" => user.account.formatted_mailing_address, 
				"PHONE_NUM" => user.phone_num,
				"EMAIL" => user.email 
			},
			important: true,
      inline_css: true,
      async: true				
		)
	end

	def self.calendar_url_notification(user, highschool)
		mandrill_mail(
			template: "guidance-url-notification",
			subject: "New calendar url has been added to #{highschool.name}",
			to: [ { email: "info@repsedge.com", name: "RepsEdge" }#,
						# { email: "caroline@verbalplusvisual.com", name: "Caroline"} #, 
						#{email: "ross.wittenberg@gmail.com", name: "RepsEdge" }
					],
			vars: {
				"HIGH_SCHOOL" => highschool.name,
				"HIGH_SCHOOL_CITY" => highschool.city,
				"HIGH_SCHOOL_STATE" => highschool.state_abbreviation,
				"URL" => user.preferred_calendars.last.url,
				"EMAIL" => user.email
			},
			important: true,
	    inline_css: true,
	    async: true				
		)
	end

	def self.profile_error(user, highschool, error)
		mandrill_mail(
			template: "profile-error",
			subject: "An error has been reported for #{highschool.name}",
			to: [ { email: "info@repsedge.com", name: "RepsEdge" },
							#{email: "info@repsedge.com", name: "RepsEdge" }
					],
			vars: {
				"HIGH_SCHOOL" => highschool.name,
				"ERROR" => error,
				"EMAIL" => user.email
			},
			important: true,
	    inline_css: true,
	    async: true				
		)
	end

	def self.missing(user, missing)
		mandrill_mail(
			template: "school-missing",
			subject: "A missing school has been reported.",
			to: [ { email: "info@repsedge.com", name: "RepsEdge" },
							#{email: "info@repsedge.com", name: "RepsEdge" }
					],
			vars: {
				"MISSING" => missing,
				"EMAIL" => user.email
			},
			important: true,
	    inline_css: true,
	    async: true				
		)
	end

	# def self.purchase_order_confirmation(user)
	# 	mandrill_mail(
	# 		template: "po-order-confirmation",
	# 		subject: "RepsEdge Purchase Order Confirmation",
	# 		to: [ { email: "info@repsedge.com", name: "RepsEdge" }, 
	# 					{email: user.email, name: "#{user.first_name} #{user.last_name}" } ],
	# 		vars: {
	# 			"PLAN_LEVEL"	 => user.institution.plan_level,
	# 			"PLAN_YEARS"	 => user.account.plan_years, 
	# 			"PLAN_PRICE"	 => number_to_currency(user.account.plan_price),
	# 			"INSTITUTION"	 => user.institution.name,
	# 			"FIRST_NAME"	 => user.first_name,
	# 			"LAST_NAME"	 => user.last_name,
	# 			"INSTITUTION_ADDRESS_PART_1"	 => user.institution.street_address,
	# 			"INSTITUTION_ADDRESS_PART_2"	 => user.institution.formatted_mailing_address,
	# 			"PHONE_NUM"	 => user.phone_num,
	# 			"EMAIL"	 => user.email, 
	# 			"BILLING_ADDRESS_PART_1"	 => user.account.formatted_street_address,
	# 			"BILLING_ADDRESS_PART_2"	 => user.account.formatted_mailing_address, 
	# 			"PAYMENT_TYPE"	 => user.account.payment_type,
	# 			"ORDER_NUM"	 => user.account.order_num

	# 		},
	# 		important: true,
 #      inline_css: true,
 #      async: true				
	# 	)
	# end

	def self.purchase_order_invoice(user)
		mandrill_mail(
			template: "purchase-order",
			subject: "Invoice: RepsEdge Purchase Order",
			to: [ { email: "info@repsedge.com", name: "RepsEdge" }, 
						{email: user.email, name: "#{user.first_name} #{user.last_name}" } ],
			vars: {
				"PLAN_LEVEL"	 => user.institution.plan_level,
				"PLAN_YEARS"	 => user.account.plan_years, 
				"PLAN_PRICE"	 => number_to_currency(user.account.plan_price),
				"INSTITUTION"	 => user.institution.name,
				"FIRST_NAME"	 => user.first_name,
				"LAST_NAME"	 => user.last_name,
				"INSTITUTION_ADDRESS_PART_1"	 => user.institution.street_address,
				"INSTITUTION_ADDRESS_PART_2"	 => user.institution.formatted_mailing_address,
				"PHONE_NUM"	 => user.phone_num,
				"EMAIL"	 => user.email, 
				"BILLING_ADDRESS_PART_1"	 => user.account.formatted_street_address,
				"BILLING_ADDRESS_PART_2"	 => user.account.formatted_mailing_address, 
				"PAYMENT_TYPE"	 => user.account.payment_type,
				"ORDER_NUM"	 => user.account.order_num,
				"CREATED_AT" => user.account.created_at.strftime("%m/%d/%y")

			},
			important: true,
      inline_css: true,
      async: true				
		)
	end

	def self.weekly_agenda(user)
		
		visits_array = []
		user.visits.where(start: (Time.now.midnight - 1.day)..Time.now + 7.days).order(start: :asc).each do |visit|
		
			visitHash = visit.attributes.clone

			visitHash["start"] = visit.user_visit_start_dst_adjuster(user)
			visitHash["end"] = visit.user_visit_end_dst_adjuster(user)

			visitHash["start"] = "#{visitHash['start'].strftime('%I:%M %p')}  #{visitHash['start'].strftime('%A')}, #{visitHash['start'].strftime('%m/%d')}"
			visitHash["end"] = "#{visitHash['end'].strftime('%I:%M %p')}  #{visitHash['end'].strftime('%A')}, #{visitHash['end'].strftime('%m/%d')}"
			
			visits_array.push(visitHash)
				
		end
		
		mandrill_mail(
			template: "weekly-agenda",
			subject: "RepsEdge: Weekly Agenda for #{user.first_name} #{user.last_name}",
			to: [ #{ email: "info@repsedge.com", name: "RepsEdge" }#, 
						{email: user.email, name: "#{user.first_name} #{user.last_name}"} 
						],
			merge_language: 'handlebars',
			important: true,
      inline_css: true,
      async: true,				
			vars:
					{
						"FIRST_NAME" => user.first_name,
						"LAST_NAME" => user.last_name,
						"VISITS" => visits_array,
						"ID" => user.id
					}
			)		
	end

	def share_weekly_agenda(user, recipent_email)
		agendaStart = Time.now.in_time_zone(user.time_zone).strftime('%m/%d')
		agendaEnd = (Time.now.in_time_zone(user.time_zone) + 7.days).strftime('%m/%d')

		visits_array = []
		user.visits.where(start: (Time.now.midnight - 1.day)..Time.now + 7.days).order(start: :asc).each do |visit|
			visitHash = visit.attributes.clone

			visitHash["start"] = visit.user_visit_start_dst_adjuster(user)
			visitHash["end"] = visit.user_visit_end_dst_adjuster(user)
			
			visitHash["start"] = "#{visitHash['start'].in_time_zone(user.time_zone).strftime('%I:%M %p')}  #{visitHash['start'].in_time_zone(user.time_zone).strftime('%A')}, #{visitHash['start'].in_time_zone(user.time_zone).strftime('%m/%d')} - #{visitHash['start'].in_time_zone(user.time_zone).strftime('%Z')}"
			visitHash["end"] = "#{visitHash['end'].in_time_zone(user.time_zone).strftime('%I:%M %p')}  #{visitHash['end'].in_time_zone(user.time_zone).strftime('%A')}, #{visitHash['end'].in_time_zone(user.time_zone).strftime('%m/%d')} - #{visitHash['end'].in_time_zone(user.time_zone).strftime('%Z')}"
			
			visits_array.push(visitHash)
		end
		
		mandrill_mail(
			template: "share-weekly-agenda",
			subject: "RepsEdge: Weekly Agenda for #{user.first_name} #{user.last_name}",
			to: [ #{ email: "info@repsedge.com", name: "RepsEdge" }, 
						{email: recipent_email } 
						],
			merge_language: 'handlebars',
			important: true,
      inline_css: true,
      async: true,				
			vars:
					{
						"AGENDA_START" => agendaStart,
						"AGENDA_END" => agendaEnd,	
						"FIRST_NAME" => user.first_name,
						"LAST_NAME" => user.last_name,
						"VISITS" => visits_array
					}
			)
	end

	def prospective_students_mail(user, subject, content, prospective_students)
		emailsHashArray = []
		prospective_students.each do |ps| 
			emailsHashArray.push({email: ps.email, name: "#{ps.first_name} #{ps.last_name}"})
		end
		recipientsArray = []
		prospective_students.each do |ps| 
			recipientsHash = ps.attributes.clone
			recipientsArray.push(recipientsHash)
		end
		mandrill_mail(
			template: "prospective-students-mail",
			subject: subject,
			to: emailsHashArray,
			merge_language: 'handlebars',
			important: true,
      inline_css: true,
      async: true,				
			vars:
					{ 
						"CONTENT" => content,
						"SUBJECT" => subject
					}
			)
	end

	def prospective_students_mail_test(user, subject, content)

		mandrill_mail(
			template: "prospective-students-mail",
			subject: "#{subject} (test)",
			to: {email: user.email},
			merge_language: 'handlebars',
			important: true,
      inline_css: true,
      async: true,				
			vars:
					{ 
						"CONTENT" => content,
						"SUBJECT" => subject
					}
			)
	end

	def anonymous_help_contact(email, questions_comments)
		mandrill_mail(
		template: "anonymous-contact",
		subject: "Anonymous Help/Contact form submitted.",
		to: [ { email: "info@repsedge.com", name: "RepsEdge" }#, 
					# {email: user.email, name: "#{user.first_name} #{user.last_name}"}
					],
		important: true,
    inline_css: true,
    async: true,				
		vars:{
					"EMAIL" => email,
					"QUESTIONS_COMMENTS" => questions_comments
		})	
	end

	def help_contact(user, email, questions_comments)
		email_address = user.email || email
		mandrill_mail(
		template: "contact-form",
		subject: "Help/Contact form submitted by: #{user.first_name} #{user.last_name}",
		to: [ { email: "info@repsedge.com", name: "RepsEdge" }#, 
					# {email: user.email, name: "#{user.first_name} #{user.last_name}"}
					],
		important: true,
    inline_css: true,
    async: true,				
		vars:{
					"FIRST_NAME" => user.first_name,
					"LAST_NAME" => user.last_name,
					"EMAIL" => email_address,
					"QUESTIONS_COMMENTS" => questions_comments
		})
	end	

	def new_account_from_admin_email(user)
		mandrill_mail(
		template: "account-created-admin",
		subject: "A New RepsEdge account has been created for you.",
		to: [ #{ email: "info@repsedge.com", name: "RepsEdge" }#, 
					{email: user.email, name: "#{user.first_name} #{user.last_name}"}
					],
		important: true,
    inline_css: true,
    async: true,				
		vars:{
					"EMAIL" => user.email
		})
	end

end
