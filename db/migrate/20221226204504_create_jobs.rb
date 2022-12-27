class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.integer :job_id
      t.string :status
      t.text :link

      t.timestamps
    end
  end
end
