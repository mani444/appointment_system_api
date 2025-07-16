class Appointment < ApplicationRecord
  belongs_to :client
  
  validates :time, presence: true
  validate :time_in_future, on: :create

  def as_json(options = {})
    super(options.merge(
      only: [:id, :client_id, :time]
    ))
  end

  private

  def time_in_future
    return unless time
    
    if time <= Time.current
      errors.add(:time, "must be in the future")
    end
  end
end
