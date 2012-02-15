from googlemaps import GoogleMaps, GoogleMapsError
from decimal import Decimal

__all__ = ['NormalizedAddress', 'normalize_street_address']

class NormalizedAddress(object):

    def __init__(self, data):
        self.address_line1  = None
        self.address_line2  = None
        self.city           = None
        self.postal_code    = None
        self.state_province = None
        self.country        = None
        self.latitude       = None
        self.longitude      = None

        placemark = data['Placemark'][0]
        self.longitude, self.latitude = placemark['Point']['coordinates'][0:2]
        country_data = placemark['AddressDetails']['Country']
        details = country_data['AdministrativeArea']

        if details.get('SubAdministrativeArea') is not None:
            locality = details['SubAdministrativeArea']['Locality']
            self.city = locality['LocalityName']
        elif details.get('Locality') is not None:
            locality = details['Locality']
            self.city = locality['LocalityName']
        elif details.get('DependentLocality') is not None:
            locality = details['DependentLocality']
            self.city = locality['DependentLocalityName']
        else:
            raise GoogleMapsError(GoogleMapsError.G_GEO_UNKNOWN_ADDRESS)

        self.address_line1 = locality['Thoroughfare']['ThoroughfareName']

        # Break out any suite number, since it's not broken out in the data.
        try:
            i = self.address_line1.index('#')
            self.address_line2 = self.address_line1[i:].strip()
            self.address_line1 = self.address_line1[:i-1].strip()
        except ValueError:
            pass

        self.state_province = details['AdministrativeAreaName']
        self.postal_code = locality['PostalCode']['PostalCodeNumber']
        self.country = country_data['CountryName']
        self.formatted_address = placemark.get('AddressDetails', {}).get('address')
        if self.formatted_address is None:
            fields = [
                self.address_line1, self.address_line2, self.city,
                self.state_province, self.postal_code, self.country
            ]
            self.formatted_address = ' '.join([
                x for x in fields if (x is not None) and (x.strip() != '')
            ])

    def __str__(self):
        return self.formatted_address

    def __repr__(self):
        return str(self.__dict__)

def normalize_street_address(raw_address_string):

    gm = GoogleMaps() # Add API key for premium Google Maps service
    result = None

    try:
        data = gm.geocode(raw_address_string)
        if data is not None:
            result = NormalizedAddress(data)

    except KeyError:
        result = None

    except GoogleMapsError as ex:
        if ex.message != GoogleMapsError.G_GEO_UNKNOWN_ADDRESS:
            raise ex

    return result
