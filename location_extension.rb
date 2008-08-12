# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
require_dependency 'geo_kit/defaults'
require_dependency 'geo_kit/mappable'
require_dependency 'geo_kit/acts_as_mappable'
require_dependency 'geo_kit/ip_geocode_lookup'
require_dependency 'location_geo_kit'

class LocationExtension < Radiant::Extension
  version "1.0"
  description "Radiant Locator Extension"
  url "http://starkravingcoder.blogspot.com"
  
  define_routes do |map|
    # Layouts Routes
    map.with_options(:controller => 'admin/location') do |location|
      location.location_index    'admin/locations',                      :action => 'index'
      location.location_edit     'admin/locations/edit/:id',             :action => 'edit'
      location.location_new      'admin/locations/new',                  :action => 'new'
      location.location_remove   'admin/locations/remove/:id',           :action => 'remove'  
    end
  end
  
  def activate
    ActiveRecord::Base.send :include, GeoKit::ActsAsMappable
    ActionController::Base.send :include, GeoKit::IpGeocodeLookup
    admin.tabs.add  "Locations", "/admin/locations", :after => "Pages", :visibility => [:all]
    Radiant::AdminUI.class_eval do
      attr_accessor :location
    end
    admin.location = load_default_location_regions
    LocationPage
  end
  
  def deactivate
     admin.tabs.remove "Locations"
  end
  
  private
  # Defines this extension's default regions (so that we can incorporate shards
  # into its views).
  def load_default_location_regions
    returning OpenStruct.new do |location|
      location.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_title edit_group edit_full_address edit_website_url edit_page_path edit_latitude edit_longitude edit_manual_geocode}
        edit.form_bottom.concat %w{edit_timestamp edit_buttons}
      end
    end
  end
  
 



  
end