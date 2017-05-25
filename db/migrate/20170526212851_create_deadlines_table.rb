class CreateDeadlinesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :deadlines do |t|
      t.string :name
      t.references :assignment, polymorphic: true
      t.datetime :deadline_at

      t.timestamps
    end
  end
end
