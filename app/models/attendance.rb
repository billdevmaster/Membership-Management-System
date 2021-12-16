class Attendance < ApplicationRecord
  belongs_to :wkclass
  belongs_to :purchase
  # this defines the start_time method on an instance of Wkclass
  # so @attendance.start_time equals WkClass.find(@attendance.id).start_time
  # date is a Wkclass instance method that formats start_time
  delegate :start_time, :date, to: :wkclass

  def revenue
    purchase.payment / purchase.attendance_estimate
  end

  def workout_group
    purchase.product.workout_group
  end

  # # for expiry_date method of Purchase model
  # def self.order_by_date
  #   sql = "SELECT wkclasses.start_time date
  #          FROM attendances
  #          INNER JOIN wkclasses ON wkclasses.id = attendances.wkclass_id
  #          ORDER BY date ASC;"
  #     ActiveRecord::Base.connection.exec_query(sql).to_a
  # end

  def self.by_workout_group(workout_group, start_date, end_date)
      attendance_ids = WorkoutGroup.joins(products: [purchases: [attendances: [:wkclass]]])
                                   .where("wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'")
                                   .where(workout_group_condition(workout_group))
                                   .order(:start_time)
                                   .select('attendances.id').to_a.map(&:id)
      Attendance.find(attendance_ids)
  end

  def self.by_date(start_date, end_date)
    # note wkclass belongs to attendance so wkclass not wkclasses
    attendance_ids = WorkoutGroup.joins(products: [purchases: [attendances: [:wkclass]]])
                                 .where("wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'")
                                 .order(:start_time)
                                 .select('attendances.id').to_a.map(&:id)
    Attendance.find(attendance_ids)
    # equivalent method calling sql directly without rails helper methods
    # sql = "SELECT attendances.id
    #        FROM Workout_Groups
    #        INNER JOIN Products ON Workout_Groups.id = Products.workout_group_id
    #        INNER JOIN Purchases ON Products.id = Purchases.product_id
    #        INNER JOIN Attendances ON Purchases.id = Attendances.purchase_id
    #        INNER JOIN Wkclasses ON Attendances.wkclass_id = Wkclasses.id
    #        WHERE Wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'
    #        ORDER BY Wkclasses.start_time;"
    #   # convert the query result to an array of hashes [ {id: 1}, {id: 3},...] and then to an array of ids
    #   attendance_ids = ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:values)
    #   # return an array of objects, by using the find method with an array parameter
  end

  def self.by_client(clientid, start_date, end_date)
    sql = "SELECT attendances.id
           FROM Clients
           INNER JOIN Purchases ON Clients.id = Purchases.client_id
           INNER JOIN Attendances ON Purchases.id = Attendances.purchase_id
           INNER JOIN Wkclasses ON Attendances.wkclass_id = Wkclasses.id
           WHERE Wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'
           AND Clients.id = '#{clientid}'
           ORDER BY WkClasses.start_time desc;"
      # convert the query result to an array of hashes [ {id: 1}, {id: 3},...] and then to an array of ids
      attendance_ids = ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:values)
      # return an array of objects, by using the find method with an array parameter
      Attendance.find(attendance_ids)
  end

  private
    # https://api.rubyonrails.org/v6.1.4/classes/ActiveRecord/QueryMethods.html#method-i-where
    # If an array is passed, then the first element of the array is treated as a template, and the remaining elements are inserted into the template to generate the condition.
    def self.workout_group_condition(selection)
      ["workout_groups.name = ?", "#{selection}"] unless selection == 'All'
    end
end
