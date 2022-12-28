class CreateCorpus < ActiveRecord::Migration[7.0]
  def change
    create_table :corpus do |t|
      t.text :line

      t.timestamps
    end
  end
end
