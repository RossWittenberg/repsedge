class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def mobile_device?
  	request.user_agent =~ /Mobile|webOS/
  end

  helper_method :mobile_device?

  def force_html
   if request.format == :html && !params[:format]
     redirect_to format: :html
   end
  end
  
end	
