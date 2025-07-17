class Client < ApplicationRecord
  before_validation :normalize_email
  
  validates :name, presence: { message: "is required" }, 
                   length: { minimum: 2, maximum: 100, 
                            too_short: "must be at least 2 characters", 
                            too_long: "must be no more than 100 characters" }
  
  validates :email, presence: { message: "is required" }, 
                    uniqueness: { case_sensitive: false, message: "is already registered" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  
  validates :phone, presence: { message: "is required" },
                    length: { minimum: 10, maximum: 15, 
                             too_short: "must be at least 10 digits", 
                             too_long: "must be no more than 15 digits" }

  has_many :appointments, dependent: :destroy

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :email, :phone]
    ))
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip if email.present?
  end
end
