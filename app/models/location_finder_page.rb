class LocationFinderPage < Page
  include Radiant::Taggable
  include GeoKit::Geocoders
  description 'A page to show locations.'
  
  desc %{
    The root location element. 

    Retrieves locations based on the supplied parameters. Permitted parameters are:

    * *origin*      -- The address from which to start searching
    * *lat* & *lng* -- The coordinates of the origin from which to start searching. These override the *origign* attribute
    * *distance*    -- Find all the locations within the supplied distance
    * *units*       -- The units to use for distance calculations (km or miles)
    * *limit*       -- Limits the number of locations to show
    * *offset*      -- The number of the first result (for pagination)

    Attributes:
    * *group*       -- When supplied, it will show only those locations in the given group
  }
  tag "location" do |tag|
    unless tag.attr["group"].blank?
      @options[:conditions] = {:group => tag.attr['group']}
    end

    tag.locals.location = Location.find(:first, @options)
    tag.expand if tag.locals.location
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
    
    pre = tag.attr.include?('precision') ? tag.attr['precision'].to_i : 1
    
    "%01.#{pre}f" % (tag.locals.location.distance || 0)
    
  end
  
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
  
end