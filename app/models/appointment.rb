class Appointment < ApplicationRecord
  belongs_to :client
  
  validates :time, presence: { message: "is required" }
  validate :time_in_future, on: :create
  validate :time_not_too_far_in_future

  def as_json(options = {})
    super(options.merge(
      only: [:id, :client_id, :time]
    ))
  end

  private

  def time_in_future
    return unless time
    
    if time <= Time.current
      errors.add(:time, "must be scheduled for a future date and time")
    end
  end

  # Don't allow scheduling more than a year out
  def time_not_too_far_in_future
    return unless time
    
    if time > 1.year.from_now
      errors.add(:time, "cannot be scheduled more than 1 year in advance")
    end
  end
end
