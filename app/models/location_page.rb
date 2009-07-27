class LocationPage < Page
  include Radiant::Taggable
  include GeoKit::Geocoders
  description %{
    TODO: Describe the Location page type
  }


  desc %{
    The root location element. 

    Retrieves locations based on the supplied parameters. Permitted parameters are:

    * *origin*      -- The address from which to start searching
    * *lat* & *lng* -- The coordinates of the origin from which to start searching. These override the *origign* attribute
    * *distance*    -- Find all the locations within the supplied distance
    * *units*       -- The units to use for distance calculations (km or miles)
    * *count*       -- The number of results to show
    * *offset*      -- The number of the first result (for pagination)

    Attributes:
    * *group*       -- When supplied, it will show those locations with a matching group value
  }
  tag "location" do |tag|
    #TODO Clone the options rather than modifying the instance so that the tag 
    #       can be reused on the page
    unless tag.attr["group"].blank?
      @options[:conditions] = {:group => tag.attr[group]}
    end

    tag.locals.locations = Location.find(:all, @options)
    tag.expand
  end

  desc %{
    loops through each of the locations
  }
  tag "location:each" do |tag|
    st = tag.attr.include?('offset') ? tag.attr['offset'].to_i : 0
    en = tag.attr.include?('length') ? tag.attr['length'].to_i - st : -1
    each_location tag, st, en
  end
  tag "location:first" do |tag| 
    st = 0
    en = tag.attr.include?('length') ? tag.attr['length'].to_i : 1
    each_location tag, st, en
  end
  tag "location:last" do |tag| 
    st = tag.attr.include?('length') ? - tag.attr['length'].to_i : -2
    en = -1
    each_location tag, st, en
  end
  tag "location:count" do |tag|
    tag.locals.locations.length
  end
  tag "location:has_next?" do |tag| 
    (tag.locals.locations.length - tag.locals.location_index) > 1
  end
  tag "location:index" do |tag| 
    tag.locals.location_index
  end

  tag "location:if_distance" do |tag| 
    if tag.locals.location.respond_to?("distance")
      tag.expand
    end
  end
  tag "location:unless_distance" do |tag| 
    if !tag.locals.location.respond_to?("distance")
      tag.expand
    end
  end
  tag "location:distance" do |tag|
    tag.locals.location.distance
  end
  
  [:full_address, :group, :website_url, :name, :lat, :lng].each do |method|
    desc %{ returns the #{method} attribute of the Location}
    tag("#{method.to_s}") do |tag|
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
    return unless tag.locals.location.page_path?
    printf tag.locals.location.page_path
    
    if Page.find_by_url tag.locals.location.page_path
      tag.expand
    end
  end
  # tag "location:map" do |tag| 
  #   #content = '<script type="text/javascript" src="http://www.google.com/jsapi?key=#{Radiant::Config['geokit.geocoders.google']}"></script>'
  #   
  # end

  def process(request,response)
    # Parameters
    # origin = Address string (if lat and lng are defined they are used preferentially)
    # lat = latitude of origin
    # lng = longitude of origin
    # distance = distance to search within
    # units = the units to apply to the distance (km or miles)
    # count = the number of results to return
    # offset = The result number to start with

    @origin   = request.parameters["origin"]
    @lat      = request.parameters["lat"]
    @lng      = request.parameters["lng"]
    @distance = request.parameters["distance"]
    @units    = request.parameters["units"]
    @count    = request.parameters["count"]
    @offset   = request.parameters["offset"]

    if @lat.blank? || @lng.blank?
      unless @origin.blank?
        geocode = MultiGeocoder.geocode(@origin)
        logger.debug("geocode: #{geocode}")
        @origin_geo = geocode if geocode.success
      else
        @origin_geo = nil;
      end
    else
      @origin_geo = [@lat.to_f, @lng.to_f]
    end

    @options = {}
    unless @origin_geo.nil?
      @options[:origin] = @origin_geo
      @options[:order] = "distance"
    end
    unless @distance.blank?
      @options[:within] = @distance
    end
    unless @units.blank?
      @options[:units] = @units
    end
    unless @count.blank?
      @options[:limit] = @count
    end
    unless @offset.blank?
      @options[:offset] = @offset
    end

    super request, response
  end
  def cache?
     false
   end
   
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