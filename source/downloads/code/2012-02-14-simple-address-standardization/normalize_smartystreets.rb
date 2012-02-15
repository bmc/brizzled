# Address Normalizer API using the SmartyStreets LiveAddress REST API.

require 'cgi'
require 'json'
require 'net/http'
require 'street_address'

module AddressNormalizer

  API_KEY    = 'your_api_key_goes_here'
  URL        = 'api.qualifiedaddress.com'
  AUTH_TOKEN = CGI::escape(API_KEY)

  class NormalizedAddress

    Attrs = [:address_line1, :address_line2, :city, :state_province,
             :postal_code, :country, :longitude, :formatted_address]

    attr_reader *Attrs

    LINE1_KEYS = ['primary_number', 'street_name', 'street_suffix',
                  'street_postdirection']
    LINE2_KEYS = ['secondary_designator','secondary_number']
    ZIP_KEYS   = ['zipcode', 'plus4_code']

    def initialize(data)

      @address_line1  = assemble(LINE1_KEYS, data)
      @address_line2  = assemble(LINE2_KEYS, data)
      @city           = data['city_name']
      @postal_code    = assemble(ZIP_KEYS, data, '-')
      @state_province = data['state_abbreviation']
      @country        = 'US'
      @latitude       = nil
      @longitude      = nil

      formatted_fields = [@address_line1, @address_line2, @city, @state_province]
      @formatted_address = cond_join(formatted_fields, ', ') + " " + @postal_code
    end

    def to_s
      @formatted_address
    end

    def inspect
      Hash[ Attrs.map {|field| [field, self.send(field)]} ]
    end

    private

    def assemble(keys, data, sep=' ')
      s = cond_join(keys.map {|k| data[k]}, sep)
      s.strip.length == 0 ? nil : s
    end

    def cond_join(items, sep=' ')
      items.select {|i| (! i.nil?) && i.strip.length > 0}.join(sep).strip
    end
  end
  
  def normalize_street_address(raw_address_string)

    parsed = StreetAddress::US.parse_address(raw_address_string)
    raise "Cannot parse address #{raw_address_string}" if parsed.nil?

    address1 = "#{parsed.number} #{parsed.street} #{parsed.street_type}"
    params = {
      "candidates" => "1",
      "auth-token" => AUTH_TOKEN,
      "street"     => CGI::escape(address1),
      "city"       => CGI::escape(parsed.city),
      "state"      => CGI::escape(parsed.state)
    }

    params["secondary"] = parsed.unit if parsed.unit
    params["zipcode"] = parsed.postal_code if parsed.postal_code

    query = "/street-address/?" + params.map {|k, v| "#{k}=#{v}"}.join('&')

    http = Net::HTTP.new(URL)
    request = Net::HTTP::Get.new(query)
    response = JSON.parse(http.request(request).body)
    if response and (response.length > 0) and response[0]['components']
      normalized_address = NormalizedAddress.new(response[0]['components'])
    else
      normalized_address = nil
    end

    normalized_address
  end
end
