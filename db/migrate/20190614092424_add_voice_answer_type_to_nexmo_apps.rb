class AddVoiceAnswerTypeToNexmoApps < ActiveRecord::Migration[6.0]
  def change
    add_column :nexmo_apps, :voice_answer_type, :integer, default: 0, index: true
    remove_column :nexmo_apps, :voice_answer_ncco, :text
  end
end
