class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
       config_properties.sort.each do |i, j|
          Radiant::Config[i[0]] = i[1] 
        end
    end
  end

  def self.down
     config_properties.sort.each do |i, j|
        Radiant::Config[i[0]] = nil
      end
  end
  private
  def self.config_properties
     {
      "geokit.default_units" => "miles",
      "geokit.default_formula" => "sphere",     
      "geokit.geocoders.proxy_addr" => "nil",
      "geokit.geocoders.proxy_port" => "nil",
      "geokit.geocoders.proxy_user" => "nil",
      "geokit.geocoders.proxy_pass" => "nil",
      "geokit.geocoders.timeout" => "nil",
      "geokit.geocoders.yahoo" => 'REPLACE_WITH_YOUR_YAHOO_KEY',
      "geokit.geocoders.google" => 'ABQIAAAAPQQInONSMwhvAM8XPWFx-RTpPmlDLmOF7EH7MKNUxLkSYMym1hSi_821IMLTFmwgeSMyEREJZhabWQ',
      "geokit.geocoders.geocoder_us" => false,
      "geokit.geocoders.geocoder_ca" => false,
      "geokit.geocoders.provider_order" => "google us",
      "location.page_size"  => 20
     }
   end
end
