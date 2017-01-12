require 'devise/strategies/authenticatable'
 
module Devise
  module Strategies
    class AuthenticateAsPaid < Authenticatable
      def valid?
        true
      end
      def authenticate!
        Rails.logger.info("YOU ARE HITTING AUTHENTICATE!!!!!")
        Rails.logger.info(params[:user])
        if params[:user]
          user = User.find_by_email(params[:user][:email])
          if user && user.account_manager?
            if !user.account || (user.account && !user.account.is_paid?)
              fail!("There is an issue with your account. Please contact info@RepsEdge.com" )
            end
          end
        end
      end 
    end 
  end 
end
 
Warden::Strategies.add(:authenticate_as_paid, Devise::Strategies::AuthenticateAsPaid)

