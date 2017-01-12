if defined?(ActionMailer)
  class DeviseMailer < Devise::Mailer
    
    include Devise::Mailers::Helpers

    class MandrillDeviseMailer < MandrillMailer::TemplateMailer
      default from: "info@repsedge.com", from_name: "RepsEdge"
      
      def confirmation_instructions(record, confirmation_url, opts={}) 
        if record.unconfirmed_email
          mandrill_mail(
            template: "email-updated",
            subject: "RepsEdge Email Update Confirmation",
            to: [ {email: record.email, name: "#{record.first_name} #{record.last_name}" } ],
            vars: {
              "CONFIRMATION_URL" => confirmation_url
            },
            important: true,
            inline_css: true,
            async: true       
          )
        else
          mandrill_mail(
            template: "account-invite",
            subject: "New Rep Confirmation: #{record.first_name} #{record.last_name}",
            to: [ { email: "info@repsedge.com", name: "RepsEdge" }, 
                  {email: record.email, name: "#{record.first_name} #{record.last_name}" } ],
            vars: {
              "INSTITUTION" => record.institution.name,
              "CONFIRMATION_URL" => confirmation_url
            },
            important: true,
            inline_css: true,
            async: true       
          )
        end
      end

      def reset_password_instructions(record, reset_password_url, opts={})
        mandrill_mail(
          template: "password-reset",
          subject: "RepsEdge: Password Reset",
          to: [ { email: "info@repsedge.com", name: "RepsEdge" }, 
                {email: record.email, name: "#{record.first_name} #{record.last_name}" } ],
          vars: {
            "PASSWORD_RESET_URL" => reset_password_url
          },
          important: true,
          inline_css: true,
          async: true       
          )
      end
    end 
    
    def confirmation_instructions(record, token, opts={})
      confirmation_url = user_confirmation_url(record, confirmation_token: token)
      if record.rep? || record.unconfirmed_email
        MandrillDeviseMailer.confirmation_instructions(record, confirmation_url, opts={}).deliver
      end  
    end

    def reset_password_instructions(record, token, opts={})
      reset_password_url = edit_user_password_url(record, reset_password_token: token )
      MandrillDeviseMailer.reset_password_instructions(record, reset_password_url, opts={}).deliver
    end

  end
end