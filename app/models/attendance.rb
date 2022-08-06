class Attendance < ApplicationRecord
  belongs_to :wkclass
  belongs_to :purchase
  # allowed to be zero
  has_one :penalty, dependent: :destroy
  # delegate :start_time... defines the start_time method for instances of Attendance
  # so @attendance.start_time equals WkClass.find(@attendance.id).start_time
  # date is a Wkclass instance method that formats start_time
  delegate :start_time, :date, :time, to: :wkclass
  delegate :client, to: :purchase
  delegate :name, to: :client, prefix: :client
  delegate :product, to: :purchase
  scope :in_cancellation_window, -> { joins(:wkclass).merge(Wkclass.in_cancellation_window) }
  scope :amnesty, -> { where(amnesty: true) }
  scope :no_amnesty, -> { where.not(amnesty: true) }
  scope :confirmed, -> { where(status: Rails.application.config_for(:constants)['attendance_statuses'] - ['booked']) }
  scope :attended, -> { where(status: 'attended') }
  scope :committed, -> { where(status: %w[booked attended]) }
  # scope :provisional, -> { where(status: Rails.application.config_for(:constants)["attendance_statuses"]) }
  # scope :committed, lambda {
  #                       where(status: Rails.application.config_for(:constants)['attendance_statuses'] - ['cancelled early', 'cancelled late'])
  #                     }
  scope :order_by_date, -> { joins(:wkclass).order(start_time: :desc) }
  scope :order_by_status, -> { joins(purchase: [:client]).order(:status, :first_name) }

  validates :status, inclusion: { in: Rails.application.config_for(:constants)['attendance_statuses'] }

  def self.applicable_to(wkclass, client)
    joins(:wkclass).where(wkclasses: { id: wkclass.id })
                   .joins([purchase: [:client]])
                   .where(clients: { id: client.id })
                   .first
  end

  def revenue
    return 0 if amnesty?

    purchase.payment / purchase.attendance_estimate
  end

  def workout_group
    purchase.product.workout_group
  end

  def maxed_out_amendments?
    amendment_count >= Rails.application.config_for(:constants)['settings'][:amendment_count]
  end

  def self.by_status(wkclass, status)
    # sort_order = Rails.application.config_for(:constants)["attendance_status"]
    joins(:wkclass, purchase: [:client])
      .where(wkclasses: { id: wkclass.id })
      .where(status: status)
      .order(:first_name)
    # .select('attendances.status', 'clients.first_name')
    # .to_a.sort_by { |a| [sort_order.index(a.status), a.first_name] }
  end

  def self.by_workout_group(workout_group_name, period)
    joins(:wkclass, purchase: [product: [:workout_group]])
      .merge(Wkclass.during(period))
      .where(workout_group_condition(workout_group_name))
      .order(:start_time)
  end

  # https://api.rubyonrails.org/v6.1.4/classes/ActiveRecord/QueryMethods.html#method-i-where
  # If an array is passed, then the first element of the array is treated as a template, and the remaining elements are inserted into the template to generate the condition.
  def self.workout_group_condition(selection)
    ['workout_groups.name = ?', selection.to_s] unless selection == 'All'
  end
end
