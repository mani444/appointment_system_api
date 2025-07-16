class Client < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true

  has_many :appointments, dependent: :destroy

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :email, :phone]
    ))
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
