# -------------from Client.rb
# doest seem to be performant
# scope :cold2, -> { Client.where('id IN (?)',
#                     Client
#                     .select('clients.id', 'max(start_time) as max')
#                     .joins(purchases: [attendances: [:wkclass]])
#                     .group('clients.id')
#                     .having("max(start_time) < ?", 3.months.ago)
#                     .pluck(:id))
#                 }
# -------------from Attendance.rb
# couldn't quite get to work with paramterised date and unsure how filter works.
# but seemed to give correct answer with the chosen dates
# def self.not_used_on?
#   sql = "WITH v1 AS (
#            SELECT p.id AS pid, w.start_time as wstart
#            FROM purchases p
#            INNER JOIN attendances a ON p.id = a.purchase_id
#            INNER JOIN wkclasses w ON a.wkclass_id = w.id
#                   )
#            SELECT pid
#            FROM v1
#            GROUP BY pid HAVING COUNT(*) FILTER (WHERE wstart BETWEEN '2022-03-23' AND '2022-03-24') = 0;"
#   ActiveRecord::Base.connection.exec_query(sql)
# end


# -------------from Attendance.rb
# def self.by_workout_group(workout_group, start_date, end_date)
#     attendance_ids = WorkoutGroup.joins(products: [purchases: [attendances: [:wkclass]]])
#                                  .where("wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'")
#                                  .where(workout_group_condition(workout_group))
#                                  .order(:start_time)
#                                  .select('attendances.id').to_a.map(&:id)
#     Attendance.find(attendance_ids)
# end

# def self.by_workout_group(workout_group_name, start_date, end_date)
#     joins(:wkclass, purchase: [product: [:workout_group]])
#    .where("wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'")
#    .where(workout_group_condition(workout_group_name))
#    .order(:start_time)
# end

# def self.for_client_purchase(clientid, purchaseid)
#    joins(:wkclass, purchase: [product: [:workout_group]])
#   .joins(purchase: [:client])
#   .where(clients: {id: clientid})
#   .where(purchase_condition(purchaseid))
#   .order(dop: :desc, start_time: :asc)
# end

# def self.purchase_condition(selection)
#   ["purchases.id = ?", "#{selection}"] unless selection == 'All'
# end

# def self.by_date(start_date, end_date)
#   # note wkclass belongs to attendance so wkclass not wkclasses
#   attendance_ids = WorkoutGroup.joins(products: [purchases: [attendances: [:wkclass]]])
#                                .where("wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'")
#                                .order(:start_time)
#                                .select('attendances.id').to_a.map(&:id)
#   Attendance.find(attendance_ids)
#   # equivalent method calling sql directly without rails helper methods
#   # sql = "SELECT attendances.id
#   #        FROM Workout_Groups
#   #        INNER JOIN Products ON Workout_Groups.id = Products.workout_group_id
#   #        INNER JOIN Purchases ON Products.id = Purchases.product_id
#   #        INNER JOIN Attendances ON Purchases.id = Attendances.purchase_id
#   #        INNER JOIN Wkclasses ON Attendances.wkclass_id = Wkclasses.id
#   #        WHERE Wkclasses.start_time BETWEEN '#{start_date}' AND '#{end_date}'
#   #        ORDER BY Wkclasses.start_time;"
#   #   # convert the query result to an array of hashes [ {id: 1}, {id: 3},...] and then to an array of ids
#   #   attendance_ids = ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:values)
#   #   # return an array of objects, by using the find method with an array parameter
# end

# -------------from Client.rb
# def self.cold
#     sql = "SELECT client_id, max(start_time)
#            FROM clients INNER JOIN purchases ON purchases.client_id = clients.id
#            INNER JOIN attendances ON attendances.purchase_id = purchases.id
#            INNER JOIN wkclasses ON attendances.wkclass_id = wkclasses.id
#            GROUP BY client_id
#            HAVING max(start_time) > CURRENT_DATE - INTERVAL '1 months';"
#     ActiveRecord::Base.connection.exec_query(sql).to_a
# end

# -------------from Wkclass.rb
# def self.by_date(start_date, end_date)
#   Wkclass.where("start_time BETWEEN '#{start_date}' AND '#{end_date}'")
#          .order(:start_time)
# end

# # for qualifying purchases in select box for new attendance form
# def self.clients_with_purchase_for(wkclass)
#   # note: If the column in select is not one of the attributes of the model on which the select is called on then those columns are not displayed. All of these attributes are still contained in the objects within AR::Relation and are accessible as any other public instance attributes.
#   client_purchase_ids =
#   WorkoutGroup.joins(products: [purchases: [:client]]).merge(WorkoutGroup.includes_workout_of(wkclass)).merge(Purchase.not_expired)
#   .order("clients.first_name", "purchases.dop")
#   .select('clients.id as clientid, purchases.id as purchaseid')
#   client_purchase_ids.to_a.select do |cp|
#     purchase = Purchase.find(cp["purchaseid"])
#     !purchase.expired? &&!purchase.provisionally_expired? && !purchase.freezed?(wkclass.start_time)
#    end
# end

# previous for clients_with_purchase_for with lots of nested joins and no scope on association
# def self.clients_with_product(wkclass)
#   client_purchase_ids =
#    Wkclass.joins(workout: [rel_workout_group_workouts: [workout_group: [products: [purchases: [:client]]]]])
#           .where("wkclasses.id = #{wkclass.id}")
#           .order("clients.first_name")
#           .select('clients.id as clientid, purchases.id as purchaseid')
#   client_purchase_ids.to_a.select { |cp| !Purchase.find(cp["purchaseid"]).expired? && !Purchase.find(cp["purchaseid"]).freezed?(wkclass.start_time) }
# end

# alternative code with direct SQL rather than Active record helper methods
# def self.clients_with_product(wkclass)
#   sql = "SELECT clients.id AS clientid, purchases.id AS purchaseid
#          FROM Wkclasses
#           INNER JOIN workouts ON wkclasses.workout_id = workouts.id
#           INNER JOIN rel_workout_group_workouts rel ON workouts.id = rel.workout_id
#           INNER JOIN workout_groups ON rel.workout_group_id = workout_groups.id
#           INNER JOIN products on workout_groups.id = products.workout_group_id
#           INNER JOIN purchases ON products.id = purchases.product_id
#           INNER JOIN clients ON purchases.client_id = clients.id
#           WHERE Wkclasses.id = #{wkclass.id} ORDER BY clients.first_name;"
#           # [{"clientid"=>1, "purchaseid"=>1}, {"clientid"=>2, "purchaseid"=>2},...
#   ActiveRecord::Base.connection.exec_query(sql).to_a.select { |cp| !Purchase.find(cp["purchaseid"]).expired? && !Purchase.find(cp["purchaseid"]).freezed?(wkclass.start_time) }
# end

# -------------from WorkoutGroup.rb
# products_hash collates the relevant attributes across 3 models which define each product
# and creates a name out of them
# a product can then be selected from a single dropdown when adding a purchase eg 'Space 1C:1D Diwali21'
#   def self.products_hash
# # attributes returns an array of hashes like below and the each loop adds the name key/value pair to it.
# # [{"wg_name"=>"Space",.."price"=>500,.."name"=>"Space UC:1W Diwali21"}, {...}, {...} ...]
#     joins(products: [:prices])
#    .select('workout_groups.name as wg_name','products.id as product_id', 'products.max_classes',
#            'products.validity_length', 'products.validity_unit', 'prices.name as price_name', 'prices.price')
#    .order('workout_groups.id', 'products.id')
#    .map(&:attributes)
#    .each { |p| p['name'] = Product.full_name(p['wg_name'], p['max_classes'],
#                p['validity_length'], p['validity_unit'], p['price_name'])
#           }
#   end