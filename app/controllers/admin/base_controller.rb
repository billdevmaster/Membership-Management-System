class Admin::BaseController < ApplicationController
  # layout 'admin' unless logged_in_as?('partner')
  # gives undefined method `logged_in_as?' for Admin::BaseController:Class
  layout :determine_layout
  before_action :admin_account
  before_action :set_public_timetable # for navigation bar 

  def update_purchase_status(purchases)
    # this has to be done as separate requests as each calc is dependent on the previously updated attribute
    # this could be avoided and done as one update request with some reformatting of the calc methods (to include an optional argument)
    purchases.each do |p|
      p.update(start_date: p.start_date_calc)
      p.update(expiry_date: p.expiry_date_calc)
      p.update(status: p.status_calc)
    end

    # p.update(
    #   { status: p.status_calc,
    #     expiry_date: p.expiry_date_calc,
    #     start_date: p.start_date_calc })
  end

  private
    def determine_layout
      'admin' # unless logged_in_as?('partner')
    end

    def set_public_timetable
      if Rails.env.test?
        @timetable = Timetable.first
      else
        @timetable = Timetable.find(Setting.timetable)
      end
    end
end
