# frozen_string_literal: true

require 'date'
require 'date_validator'

class Event < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true
  validates :eventCode, presence: true
  validates :endTime, date: { after: proc { :startTime }, allow_blank: true }

  attribute :eventCode, :string, default: -> { generate_code }

  def self.naive_now
    # Conversion to a naive time since the database stores local times for events without timezone info
    # RailsAdmin breaks if you try to use real Ruby/Rails timezone support
    Time.now.in_time_zone('Central Time (US & Canada)').change(offset: 0)
  end

  def self.ongoing
    now = naive_now
    today = now.to_date
    # now.. means in the range [now, infinity). You can interpret it as now-or-after (while ..now is before-to-now)
    where(date: today, startTime: [nil, ..now], endTime: [nil, now..])
      .order(date: :desc, startTime: :desc)
  end

  def self.upcoming
    now = naive_now
    today = now.to_date
    where(date: today, startTime: now..).or(where(date: (today + 1)..))
                                        .order(date: :asc, startTime: :asc)
  end

  def self.past
    now = naive_now
    today = now.to_date
    where(date: today, endTime: ..now).or(where(date: ..(today - 1)))
                                      .order(date: :desc, startTime: :desc)
  end

  def self.from_code(code)
    # Retrieves the most relevant event matching the code
    # Each of these categories is sorted to where the elements closest to the present come first
    ongoing.where(eventCode: code).first \
    || past.where(eventCode: code).first \
    || upcoming.where(eventCode: code).first
  end

  def self.generate_code(length = 5)
    # Ambiguous characters l and i are excluded from inclusion in a code
    valid_characters = [*('a'..'z')] - %w[i l]
    code = nil
    # Create a unique random code
    code = length.times.map { valid_characters.sample }.join until code && !Event.exists?(eventCode: code)
    code
  end
end
