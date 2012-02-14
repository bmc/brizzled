import urllib
import json
from decimal import Decimal

__all__ = ['NormalizedAddress', 'normalize_street_address']

class NormalizedAddress(object):

    def __init__(self, data):
        self.address_line1 = None
        self.address_line2  = None
        self.city           = None
        self.postal_code    = None
        self.state_province = None
        self.country        = None
        self.latitude       = None
        self.longitude      = None

        # The Google result consists of:
        #
        # - An array ("address_components") of hashes consisting of
        #   {"long_name" => "...", "short_name" => "...", "types" => [...]}
        # - A "geometry" hash, with the latitude and longitude
        # - A "partial_match" indicator (which we're ignoring)
        # - A "types" array (which we're also ignoring)

        for h in data["address_components"]:
            types = frozenset(h["types"])
            value = h["long_name"]
            if 'subpremise' in types:
                self.address_line2 = '#%s' % value
            elif 'street_number' in types:
                self.house_number = value
            elif 'sublocality' in types:
                self.city = value
            elif 'locality' in types:
                if self.city is None:
                    self.city = value
            elif 'country' in types:
                self.country = value
            elif 'postal_code' in types:
                self.postal_code = value
            elif 'route' in types:
                self.street = value
            elif 'administrative_area_level_1' in types:
                self.state_province = value

        self.address_line1 = '%s %s' % (self.house_number, self.street)

        if data["formatted_address"]:
            self.formatted_address = data["formatted_address"]
        else:
            fields = [
                self.addressline1, self.address_line2, self.city,
                self.state_province, self.postal_code
            ]
            self.formatted_address = ' '.join([
                x for x in fields if (x is not None) and (x.strip() != '')
            ])


        # Latitude and longitude

        if (data["geometry"] is not None) and (data["geometry"]["location"] is not None):
            loc = data["geometry"]["location"]
            self.latitude  = Decimal(str(loc["lat"]))
            self.longitude = Decimal(str(loc["lng"]))

    def __str__(self):
        return self.formatted_address

    def __repr__(self):
        return str(self.__dict__)

def normalize_street_address(raw_address_string):
    ACCEPTABLE_TYPES = frozenset(['street_address', 'subpremise'])

    params = (
        'address=%s' % urllib.quote(raw_address_string),
        'sensor=false'
        )
    url = 'https://maps.googleapis.com/maps/api/geocode/json?%s' % '&'.join(params)
    response = urllib.urlopen(url).read()
    data = json.loads(response)
    if data['status'] != 'OK':
        raise Exception(
            'Error on address "%s": %s' % (raw_address_string, data['status'])
        )

    results = data['results'][0]
    types = frozenset(results['types'])
    if len(ACCEPTABLE_TYPES & types) == 0:
        return None
    else:
        return NormalizedAddress(results)
