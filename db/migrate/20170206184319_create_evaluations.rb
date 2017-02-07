class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.string :number
      t.references :beneficiary, index: true, foreign_key: true
      t.references :problems_during_process, index: true, foreign_key: true
      t.date :interruptions
      t.boolean :concluded_process
      t.boolean :developing_process
      t.boolean :suspensions
      t.date :evaluation_date

      t.timestamps null: false
    end
  end
end
