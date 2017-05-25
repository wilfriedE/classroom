class AddDeadlineToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :deadline, :datetime
    add_column :group_assignments, :deadline, :datetime
  end
end
