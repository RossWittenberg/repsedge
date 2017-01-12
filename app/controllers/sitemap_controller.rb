 class SitemapController < ApplicationController
   def index
     @static_pages = [root_url, new_user_session_url, new_user_password_url, help_help_contact_url, help_about_url, help_terms_privacy_url, help_help_contact_form_url]
   end
 end
 