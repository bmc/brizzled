require 'geocoder'
require 'bigdecimal'
require 'set'

module AddressNormalizer

  class NormalizedAddress
    Geocoder::Configuration.lookup = :google

    Attrs = [:address_line1, :address_line2, :city, :state_province,
             :postal_code, :country, :longitude, :formatted_address]

    attr_reader *Attrs

    def initialize(data)
      @address_line1  = nil
      @address_line2  = nil
      @city           = nil
      @postal_code    = nil
      @state_province = nil
      @country        = nil
      @latitude       = nil
      @longitude      = nil

      # The Google result consists of:
      #
      # - An array ("address_components") of hashes consisting of
      #   {"long_name" => "...", "short_name" => "...", "types" => [...]}
      # - A "geometry" hash, with the latitude and longitude
      # - A "partial_match" indicator (which we're ignoring)
      # - A "types" array (which we're also ignoring)

      data["address_components"].each do |hash|
        types = hash["types"]
        value = hash["long_name"]
        if types.include? "subpremise"
          @address_line2 = "##{value}"
        elsif types.include? "street_number"
          @house_number = value
        elsif types.include? "sublocality"
          @city = value
        elsif types.include? "locality"
          @city = value if @city.nil?
        elsif types.include? "country"
          @country = value
        elsif types.include? "postal_code"
          @postal_code = value
        elsif types.include? "route"
          @street = value
        elsif types.include? "administrative_area_level_1"
          @state_province = value
        end
      end

      @line1 = "#{@house_number} #{@street}"

      if data["formatted_address"]
        @formatted_address = data["formatted_address"]
      else
        @formatted_address = [
          @address_line1, @address_line2, @city, @state_province, @postal_code
        ].select {|s| ! (s.nil? || s.empty?)}.join(' ')
      end

      # Latitude and longitude

      if data["geometry"] and data["geometry"]["location"]
        loc = data["geometry"]["location"]
        @latitude = BigDecimal.new(loc["lat"].to_s)
        @longitude = BigDecimal.new(loc["lng"].to_s)
      end
    end

    def to_s
      @formatted_address
    end

    def inspect
      Hash[ Attrs.map {|field| [field, self.send(field)]} ]
    end
  end
  
  ACCEPTABLE_TYPES = Set.new(["street_address", "subpremise"])

  def normalize_street_address(raw_address_string)

    normalized_address = nil

    # Geocoder.search() returns an array of results. Take the first one.
    geocoded = Geocoder.search(raw_address_string)
    if geocoded && (geocoded.length > 0)
      # Geocoder returns data that may or may not be granular enough. For
      # instance, attempting to retrieve information about nonexistent
      # address '100 Main St, XYZ, PA, US' still returns a value, but the
      # value's type is "administrative_area_level_1", which means the data
      # is granular to a (U.S.) state. If it's a valid address, we should
      # get data that's more granular than that. Of the codes listed at
      # http://code.google.com/apis/maps/documentation/geocoding/#Types
      # we're interested in "street_address", "premise" and
      # "subpremise".
      data = geocoded[0].data
      types = Set.new(data["types"])
      if !(types & ACCEPTABLE_TYPES).empty?
        normalized_address = NormalizedAddress.new(data)
      end
    end

    normalized_address
  end
end
