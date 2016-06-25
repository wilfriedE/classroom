class AddDueDateToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :due_date, :timestamp
    add_column :group_assignments, :due_date, :timestamp
  end
end
