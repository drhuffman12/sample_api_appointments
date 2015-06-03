class Appointment < ActiveRecord::Base

  before_validation :strip_outer_whitespace, on: [:create, :update]

  validates_presence_of :start_time, :end_time, :first_name, :last_name

  validate :start_time_is_valid_datetime
  validate :end_time_is_valid_datetime

  validate :start_should_be_in_future
  validate :end_should_be_in_future
  validate :start_should_be_before_end
  validate :start_should_not_overlap_existing
  validate :end_should_not_overlap_existing

  # not stated in requirements, but might be good to have:
  RE_SIMPLE_NAME = /\A(\w+)(\s+\w+)*\z/
  RE_SIMPLE_COMMENT = /(\A(\w+)(\s+\w+)*\z)*/
  validates :first_name, presence: true, format: { with: RE_SIMPLE_NAME }
  validates :last_name, presence: true, format: { with: RE_SIMPLE_NAME }
  validates :comments, format: { with: RE_SIMPLE_COMMENT }

  private

  def strip_outer_whitespace
    first_name.strip! unless first_name.nil?
    last_name.strip! unless last_name.nil?
    comments.strip! unless comments.nil?
  end

  def start_time_is_valid_datetime
    errors.add(:start_time, "must be a valid ActiveSupport::TimeWithZone! start_time.class: #{start_time.class}") unless start_time.is_a?(ActiveSupport::TimeWithZone)
  end

  def end_time_is_valid_datetime
    errors.add(:end_time, "must be a valid ActiveSupport::TimeWithZone! end_time.class: #{end_time.class}") unless end_time.is_a?(ActiveSupport::TimeWithZone)
  end

  def start_should_be_before_end
    if (start_time && end_time)
      errors.add(:start_time, "should be before end_time. start_time: '#{start_time}', end_time: '#{end_time}'") if (start_time > end_time)
    end
  end

  def start_should_be_in_future
    if (start_time)
      errors.add(:start_time, "should be in future. start_time: '#{start_time}'") if (start_time < Time.zone.now)
    end
  end

  def end_should_be_in_future
    if (end_time)
      errors.add(:end_time, "should be in future. end_time: '#{end_time}'") if (end_time < Time.zone.now)
    end
  end

  def start_should_not_overlap_existing
    if (start_time)
      if (Appointment.exists?(["(start_time <= ?) AND (? <= end_time) AND id != ?", start_time, start_time, id || 0]))
        overlaps_with_records = Appointment.select('id').where(["(start_time <= ?) AND (? <= end_time) AND id != ?", start_time, start_time, id || 0])
        errors.add(:start_time, "should not overlap existing records. Overlaps with record id's: " + overlaps_with_records.collect{ |r| r['id'] }.inspect)
      end
    end
  end

  def end_should_not_overlap_existing
    if (end_time)
      if (Appointment.exists?(["(start_time <= ?) AND (? <= end_time) AND id != ?", end_time, end_time, id || 0]))
        overlaps_with_records = Appointment.select('id').where(["(start_time <= ?) AND (? <= end_time) AND id != ?", end_time, end_time, id || 0])
        errors.add(:end_time, "should not overlap existing records. Overlaps with record id's: " + overlaps_with_records.collect{ |r| r['id'] }.inspect)
      end
    end
  end
  
end
