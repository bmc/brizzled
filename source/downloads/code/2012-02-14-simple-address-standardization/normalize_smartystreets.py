import json
import urllib
from parse_addr import parse_address

__all__ = ['NormalizedAddress', 'normalize_street_address']

API_KEY  = r'your_api_key_goes_here'
LOCATION = 'https://api.qualifiedaddress.com/street-address/'

LINE1_KEYS = ['primary_number', 'street_name', 'street_suffix',
              'street_postdirection']
LINE2_KEYS = ['secondary_designator','secondary_number']
ZIP_KEYS   = ['zipcode', 'plus4_code']

class NormalizedAddress(object):


    def __init__(self, data):
        self.address_line1  = self._assemble(LINE1_KEYS, data)
        self.address_line2  = self._assemble(LINE2_KEYS, data)
        self.city           = data['city_name']
        self.postal_code    = self._assemble(ZIP_KEYS, data)
        self.state_province = data['state_abbreviation']
        self.country        = 'US'
        self.latitude       = None
        self.longitude      = None

        formatted_fields = [
            self.address_line1, self.address_line2, self.city,
            self.state_province
        ]
        self.formatted_address = (
            self._cond_join(formatted_fields, ', ') + ' ' + self.postal_code
        )

    def __str__(self):
        return self.formatted_address

    def __repr__(self):
        return str(self.__dict__)

    def _assemble(self, keys, data, sep = ' '):
        vals = [data[k] for k in keys if data.get(k) is not None]
        return self._cond_join(vals, sep)

    def _cond_join(self, items, sep = ' '):
        trimmed = [i for i in items if (i is not None) and (len(i.strip()) > 0)]
        return sep.join(trimmed)

def normalize_street_address(raw_address_string):

    result = None
    parsed = parse_address(raw_address_string)
    if parsed is not None:
        query_data = {
            'auth-token': API_KEY,
            'street':     parsed['address1'],
            'city':       parsed['city'],
            'state':      parsed['state']
        }

        if parsed.get('zipcode') is not None:
            query_data['zipcode'] = parsed['zipcode']

        if parsed.get('address2') is not None:
            query_data['secondary'] = parsed['address2']

        try:
            url = '%s?%s' % (LOCATION, urllib.urlencode(query_data))
            response = urllib.urlopen(url).read()
            data = json.loads(response)
            if (data is not None) and (len(data) > 0):
                result = NormalizedAddress(data[0]['components'])

        except KeyError:
            result = None

    return result
