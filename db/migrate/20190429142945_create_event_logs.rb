class CreateEventLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :event_logs do |t|
      t.string :event_type
      t.text :content
      
      t.timestamps
    end
  end
end
