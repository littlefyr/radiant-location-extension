module LocationsTags
  include Radiant::Taggable
  include GeoKit::Geocoders


  desc %{
    The root location element. 

    Retrieves locations based on the supplied parameters. Permitted parameters are:

    * *limit*       -- Limits the number of locations to show
    * *offset*      -- The number of the first result (for pagination)

    Attributes:
    * *group*       -- When supplied, it will show only those locations in the given group
  }
  tag "locations" do |tag|
    options = {}
    unless tag.attr['limit'].blank?
      options[:limit] = tag.attr['limit'].to_i.to_s
      options[:offset] = tag.attr['offset']
    end
    
    unless tag.attr["group"].blank?
      options[:conditions] = {:group => tag.attr['group']}
    end
    
    options = options.merge(@options)

    tag.locals.locations = Location.find(:all, options)
    tag.expand
  end

  desc %{
    loops through each of the locations
  }
  tag "locations:each" do |tag|
    st = tag.attr.include?('offset') ? tag.attr['offset'].to_i : 0
    en = tag.attr.include?('length') ? tag.attr['length'].to_i - st : -1
    each_location tag, st, en
  end
  tag "locations:first" do |tag| 
    tag.locals.locations.first
  end
  tag "locations:last" do |tag| 
    tag.locals.locations.last
  end
  tag "locations:count" do |tag|
    tag.locals.locations.length
  end
  tag "locations:each:has_next?" do |tag| 
    (tag.locals.locations.length - tag.locals.location_index) > 1
  end
  tag "locations:each:index" do |tag| 
    tag.locals.location_index
  end
  tag "locations:each:location" do |tag| 
    tag.expand if tag.locals.location
  end
  tag "location" do |tag|
    tag.expand if tag.locals.location
  end
  
  [:full_address, :group, :website_url, :name, :lat, :lng].each do |method|
    desc %{ returns the #{method} attribute of the current Location}
    tag("location:#{method.to_s}") do |tag|
      tag.locals.location.send(method)
    end
  end

  desc %{Allows you to use page tags (such as <r:slug>, <r:title>, etc.) for the page associated with the location.}
  tag "location:page" do |tag|
    if tag.locals.location.page_path?
      tag.locals.page = Page.find_by_url tag.locals.location.page_path
      tag.expand
    end
  end
  tag "location:unless_page" do |tag|
    unless Page.find_by_url tag.locals.location.page_path
      tag.expand
    end
  end
  tag "location:if_page" do |tag|
    if Page.find_by_url tag.locals.location.page_path
      tag.expand
    end
  end
  # tag "location:map" do |tag| 
  #   #content = '<script type="text/javascript" src="http://www.google.com/jsapi?key=#{Radiant::Config['geokit.geocoders.google']}"></script>'
  #   
  # end
   
  private
  def each_location(tag, first=0, last=-1)
    rng    = Range.new first, last
    offset = ((first < 0) ? tag.locals.location.length : 0) + first
    result = []

    tag.locals.locations[rng].each_with_index do |item, idx|
      tag.locals.location_index = offset + idx
      tag.locals.location = item
      result << tag.expand
    end
    result
  end
end