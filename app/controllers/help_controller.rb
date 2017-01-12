class HelpController < ApplicationController

	def help_contact

	end

	def help_contact_form
    @user = current_user
    if @user && @user.id
      @user = current_user
      if params[:questions_comments].blank?
        flash[:share_error] = "Your message cannot be blank."
        redirect_to help_help_contact_path
      else
        flash[:share_success] = "Your message has been sent."
        @user.send_help_contact(params[:email] || @user.email, params[:questions_comments])
        redirect_to root_path
      end
    else
      if params[:questions_comments].blank?
        flash[:share_error] = "Your message cannot be blank."
        redirect_to help_help_contact_path
      else
        flash[:share_success] = "Your message has been sent."
        @user = User.new
        @user.send_anonymous_help_contact(params[:email], params[:questions_comments])
        @user.destroy
        redirect_to help_help_contact_path
      end
    end   
	end

	def about

	end

	def terms_privacy

	end

end
