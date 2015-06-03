class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.datetime :start_time, :default => Time.now.end_of_hour + 1 + 30.minutes
      t.datetime :end_time, :default => Time.now.end_of_hour + 1 + 60.minutes
      t.string :first_name
      t.string :last_name
      t.text :comments

      t.timestamps null: false
    end
  end
end
