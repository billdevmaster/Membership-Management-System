class AddInstructorIdToWkclasses < ActiveRecord::Migration[6.1]
  def change
    add_column :wkclasses, :instructor_id, :integer
    add_column :wkclasses, :instructor_cost, :integer
  end
end
