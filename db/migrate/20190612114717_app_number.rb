class AppNumber < ActiveRecord::Migration[6.0]
  def change
    add_column :nexmo_apps, :number_msisdn, :string
    add_column :nexmo_apps, :number_country, :string
  end
end
