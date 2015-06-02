class Appointment < ActiveRecord::Base

  before_validation :strip_outer_whitespace, on: [:create, :update]

  validates_presence_of :start_time, :end_time, :first_name, :last_name

  validate :start_time_is_valid_datetime
  validate :end_time_is_valid_datetime

  validate :start_before_end
  validate :start_after_now
  validate :end_after_now
  validate :start_does_not_overlap
  validate :end_does_not_overlap

  # not stated in requirements, but might be good to have:
  validates :first_name, presence: true, format: { with: $RE_SIMPLE_NAME }
  validates :last_name, presence: true, format: { with: $RE_SIMPLE_NAME }
  validates :comments, format: { with: $RE_SIMPLE_COMMENT }

  private

  def strip_outer_whitespace
    first_name.strip!
    last_name.strip!
    comments.strip!
  end

  def start_time_is_valid_datetime
    errors.add(:start_time, "must be a valid ActiveSupport::TimeWithZone! start_time.class: #{start_time.class}") unless start_time.is_a?(ActiveSupport::TimeWithZone)
  end

  def end_time_is_valid_datetime
    errors.add(:end_time, "must be a valid ActiveSupport::TimeWithZone! start_time.class: #{end_time.class}") unless end_time.is_a?(ActiveSupport::TimeWithZone)
  end

  def start_before_end
    if (start_time && end_time)
      errors.add(:end_time, "start_time should be before end_time") if (start_time > end_time)
    end
  end

  def start_after_now
    if (start_time)
      # errors.add(:start_time, "start_time should be in future") if (start_time < Time.now)
      errors.add(:start_time, "start_time should be in future") if (start_time < Time.now)
    end
  end

  def end_after_now
    if (end_time)
      # errors.add(:start_time, "start_time should be in future") if (start_time < Time.now)
      errors.add(:end_time, "end_time should be in future") if (end_time < Time.now)
    end
  end

  def start_does_not_overlap
    if (start_time)
      errors.add(:start_time, "start_time should not overlap existing records") if (Appointment.exists?(["(start_time <= ?) AND (? <= end_time)", start_time, start_time]))
    end
  end

  def end_does_not_overlap
    if (end_time)
      errors.add(:end_time, "end_time should not overlap existing records") if (Appointment.exists?(["(start_time <= ?) AND (? <= end_time)", end_time, end_time]))
    end
  end
  
end
