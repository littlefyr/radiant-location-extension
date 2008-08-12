[:default_units, :default_formula].each do |sym|
  GeoKit.class_eval <<-EOS, __FILE__, __LINE__
  def self.#{sym}
#    puts "My #{sym.to_s}"
    Radiant::Config["geokit.#{sym.to_s}"].to_sym
  end

  def self.#{sym}=(obj)
    Radiant::Config["geokit.#{sym.to_s}"] = obj
  end
  EOS
end
[:yahoo, :google, :geocoder_us, :geocoder_ca, :proxy_addr, :proxy_port, :proxy_user, :proxy_pass].each do |sym|
  GeoKit::Geocoders.class_eval <<-EOS, __FILE__, __LINE__
  def self.#{sym}
#    puts "My #{sym.to_s}"
    val = Radiant::Config["geokit.geocoders.#{sym.to_s}"]
    if val.strip.downcase.eql?("nil")
      nil
    else
      val
    end
  end

  def self.#{sym}=(obj)
    Radiant::Config["geokit.geocoders.#{sym.to_s}"] = obj
  end
  EOS
end
GeoKit::Geocoders.class_eval do
  def self.provider_order
    #    puts Radiant::Config["geokit.geocoders.provider_order"]
    Radiant::Config["geokit.geocoders.provider_order"].split(" ").map { |s| s.to_sym }
  end
  def self.timeout
    val = Radiant::Config["geokit.geocoders.timeout"]
    if val.strip.downcase.eql?("nil")
      nil
    else
      val.to_i
    end
  end
  def self.timeout=(obj)
    Radiant::Config["geokit.geocoders.timeout"] = obj
  end
end
