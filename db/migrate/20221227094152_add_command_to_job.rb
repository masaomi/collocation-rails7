class AddCommandToJob < ActiveRecord::Migration[7.0]
  def change
    add_column :jobs, :command, :text
  end
end
