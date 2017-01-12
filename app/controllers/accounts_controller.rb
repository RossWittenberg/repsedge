class AccountsController < ApplicationController
	
  respond_to :html, :json

	def credit_card_form
    @user = User.find(params[:user])
    @charge = Stripe::Charge.new
  end

	def create
    @user = User.find(params[:user_id])
    if params[:payment_type] == "Purchase Order"
      @user.account.update_attribute :payment_type, params[:payment_type]
      @user.skip_confirmation!
      if @user.save!
        @user.send_purchase_order_invoice
        render json: {user: @user, account: @user.account}
      else
        render json: {errors: @user.errors}
      end
    elsif params[:stripe_token] 
      if @user.institution.name == "RepsEdge"
        plan_id = 401
      else
        plan_id = @user.account.plan_id
      end  
      token = params[:stripe_token]
      begin
        customer = Stripe::Customer.create(
          :email => @user.email,
          :source  => token,
          :plan => plan_id
        )
        card = customer.sources.retrieve(params[:card_id])
        card.address_line1 = @user.account.billing_street_address_line_1
        unless @user.account.billing_street_address_line_2.blank?
          card.address_line2 = @user.account.billing_street_address_line_2    
        end
        card.address_city = @user.account.billing_city
        card.address_state = @user.account.billing_state
        card.address_zip = @user.account.billing_zip_code
        customer.description = "#{@user.account.plan_level} #{@user.account.plan_years} years"
        @user.stripe_id = customer.id
        @user.account.update_attribute :is_paid, true
        @user.account.update_attribute :payment_type, "Credit Card"
        @user.skip_confirmation!
        card.save 
        customer.save 
        @user.save!
        @user.send_account_activation
        rescue Stripe::CardError => e
          body = e.json_body
          render json: {errors: e.json_body}
      end  
      render json: {user: @user, customer: customer, card: card} if e.blank?
    end  
	end

  private

  def stripe_params
    params.permit :stripe_token, :payment_type
  end

end
