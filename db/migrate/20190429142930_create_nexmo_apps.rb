class CreateNexmoApps < ActiveRecord::Migration[6.0]
  def change
    create_table :nexmo_apps do |t|
      t.string :app_id
      t.string :name
      t.text   :public_key
      t.text   :private_key

      t.string :voice_answer_url
      t.string :voice_answer_method
      t.text   :voice_answer_ncco
      t.string :voice_event_url
      t.string :voice_event_method

      t.timestamps
    end

    add_index :nexmo_apps, :app_id, unique: true
  end
end
