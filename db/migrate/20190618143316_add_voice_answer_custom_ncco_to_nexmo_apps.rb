class AddVoiceAnswerCustomNccoToNexmoApps < ActiveRecord::Migration[6.0]
  def change
    add_column :nexmo_apps, :voice_answer_custom_ncco, :text, default: "[]"
  end
end
