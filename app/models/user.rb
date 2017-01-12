class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable

  require 'date'

  ROLE_ADMIN = 0
  ROLE_ACCOUNT_MANAGER = 1
  ROLE_REP = 2

  # validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_email_format_of :email, :generate_message => true

  validate :email_not_taken?, on: :create

  validates :email, confirmation: true, if: :account_manager?

  validates :password, presence: true, length: { in: 6..128 }, on: :create, if: :password_required?
  validates :password, length: { in: 6..128 }, on: :update, allow_blank: true
  validates :password, confirmation: true

  validates :phone_num, presence: true, if: :account_manager?
  validates :phone_num, format: { with: /\A([01][- .()])?(\(\d{3}\)|\d{3})[- .]*?\d{3}[- .]*\d{4}\Z/, message: "Must be a valid 10-digit phone number." }, if: :account_manager?

  validates :institution_id, presence: true, if: :account_manager?
  
  validates_format_of :last_name, :with => /[-a-z]/i, :message => "Letters only" 
  validates_format_of :first_name, :with => /[-a-z]/i, :message => "Letters only"

  # pw complexity validation:
  validate :password_complexity

  #before update modifers
  before_save :formatPhoneNumberForDB, if: :account_manager?

  # associations
  belongs_to :institution
  has_many :visits, dependent: :destroy
  accepts_nested_attributes_for :visits
  has_many :saved_searches, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :preferred_phones, dependent: :destroy
  has_many :preferred_guidance_websites, dependent: :destroy
  has_many :preferred_calendars, dependent: :destroy
  has_many :preferred_emails, dependent: :destroy
  has_many :prospective_students, dependent: :destroy
  has_one :account, dependent: :destroy


  def formatPhoneNumberForDB
    onlyNums = [];
    self.phone_num.gsub(/[0-9]/) { |match| onlyNums.push(match) }
    self.phone_num = onlyNums.join("").insert(3, "-").insert(7, "-")
  end

  private

  def password_complexity
    complexity = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./
    if password.present? and not complexity.match(password)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
  end

  def email_not_taken?
    unless (self.class.has_account.pluck(:email) & [self.email]).empty?
      errors.add :email, "has been taken"
    end
  end

  scope :has_account, -> { joins(:account).where("accounts.payment_type IS NOT NULL") } 

  public

  validate do |user|
    user.account do |account|
      next if account.valid?
        account.errors.full_messages.each do |msg|
      end
    end
  end
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  def confirm_po
    if self.account
      self.account.update_attribute :is_paid, true
      self.account.update_attribute :payment_type, "Purchase Order"
      self.send_account_activation
      self.skip_reconfirmation!
      self.save!
    end  
  end 

  def send_new_account_from_admin_email
    ApplicationMailer.new_account_from_admin_email(self).deliver
  end

  def send_account_activation
    ApplicationMailer.account_activation(self).deliver
  end

  def send_purchase_order_confirmation
    ApplicationMailer.purchase_order_confirmation(self).deliver
  end    

  def send_purchase_order_invoice
    ApplicationMailer.purchase_order_invoice(self).deliver
  end

  def send_calendar_url_notification(highschool)
    ApplicationMailer.calendar_url_notification(self, highschool).deliver
  end

  def send_weekly_agenda
    ApplicationMailer.weekly_agenda(self).deliver
  end

  def send_share_weekly_agenda(recipent_email)
    ApplicationMailer.share_weekly_agenda(self, recipent_email).deliver
  end

  def send_profile_error(highschool, error)
    ApplicationMailer.profile_error(self, highschool, error).deliver
  end

  def send_missing_school(missing)
    ApplicationMailer.missing(self, missing ).deliver
  end

  def send_help_contact(email, questions_comments)
    ApplicationMailer.help_contact(self, email, questions_comments).deliver
  end

  def send_anonymous_help_contact(email, questions_comments)
    ApplicationMailer.anonymous_help_contact(email, questions_comments).deliver
  end

  def send_prospective_students_mail(user, subject, content, prospective_students)
    ApplicationMailer.prospective_students_mail(user, subject, content, prospective_students).deliver
  end

  def send_prospective_students_mail_test(user, subject, content)
    ApplicationMailer.prospective_students_mail_test(user, subject, content).deliver
  end
  
 
  def password_required?
    role != ROLE_REP
  end   

  def account_admin?
    role == ROLE_ADMIN
  end

  def account_manager?
    role == ROLE_ACCOUNT_MANAGER
  end

  def rep?
    role == ROLE_REP
  end

  def role_string
    return "Admin" if self.role == ROLE_ADMIN
    return "Account Manager" if self.role == ROLE_ACCOUNT_MANAGER
    return "Rep" if self.role ==  ROLE_REP
  end

  def pending?
    !self.confirmed?
  end

  def same_institution?(user)
    self.institution.id == user.institution.id
  end

  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  def has_no_password?
    self.encrypted_password.blank?
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  def password_match?( password, password_confirmation )
    password == password_confirmation
  end

  def cancel_recurrence
    stripeId = self.stripe_id
    customer = Stripe::Customer.retrieve( stripeId )
    subscription_id = customer[:subscriptions].data[0].id
    customer.subscriptions.retrieve(subscription_id).delete(:at_period_end => true)
  end

  def time_zone_mapping
    ActiveSupport::TimeZone::MAPPING[self.time_zone]
  end

  def export_visits_to_csv
    attributes = %w{rep_first_name rep_last_name title location category date_created description time_zone contact high_school_name start_date start_time end_date end_time confirmed}
    if Time.now.month >= 8
      startDate = Date.new( Time.now.year, 8, 1)
      endDate = endDate = Date.new( (Time.now.year.+1), 6, 30)
    else
      startDate = Date.new( (Time.now.year.-1), 8, 1)
      endDate = endDate = Date.new( (Time.now.year), 6, 30)
    end
    visits = self.visits
    if self.visits.present?
      CSV.generate( { headers: true } ) do |csv|
        csv << attributes
        visits.order(startDateTime: :desc).each do |visit|
          high_school = HighSchool.find visit.high_school_id unless visit.high_school_id.blank?
          csv << [ (self.first_name || "N/A"), (self.last_name || "N/A"), visit.title, visit.location, visit.category, visit.created_at.strftime("%m/%d/%Y"), visit.description, visit.time_zone, visit.contact,( high_school && high_school.name || "N/A"), visit.start_dst_adjuster.strftime("%m/%d/%Y"), visit.start_dst_adjuster.strftime("%I:%M %p"), visit.end_dst_adjuster.strftime("%m/%d/%Y"), visit.end_dst_adjuster.strftime("%I:%M %p"), ( visit.category == "High School Visit" ? (visit.confirmed? ? "Confirmed" : "Tentative") : "N/A") ]
        end 
      end
    else
      return "You have no visits"
    end  
  end

end

