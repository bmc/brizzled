# Quick and dirty street address parser, in Python.
#
# WARNING: THIS IS NOT ROBUST! A Python port of the Ruby StreetAddress gem
# would be a better solution.

import re

__all__ = ['parse_address']

STATE_NAMES = [
    'AL', 'Alabama',
    'AK', 'Alaska',
    'AS', 'America Samoa',
    'AZ', 'Arizona',
    'AR', 'Arkansas',
    'CA', 'California',
    'CO', 'Colorado',
    'CT', 'Connecticut',
    'DE', 'Delaware',
    'DC', 'District of Columbia',
    'FM', 'Micronesia',
    'FL', 'Florida',
    'GA', 'Georgia',
    'GU', 'Guam',
    'HI', 'Hawaii',
    'ID', 'Idaho',
    'IL', 'Illinois',
    'IN', 'Indiana',
    'IA', 'Iowa',
    'KS', 'Kansas',
    'KY', 'Kentucky',
    'LA', 'Louisiana',
    'ME', 'Maine',
    'MH', 'Islands1',
    'MD', 'Maryland',
    'MA', 'Massachusetts',
    'MI', 'Michigan',
    'MN', 'Minnesota',
    'MS', 'Mississippi',
    'MO', 'Missouri',
    'MT', 'Montana',
    'NE', 'Nebraska',
    'NV', 'Nevada',
    'NH', 'New Hampshire',
    'NJ', 'New Jersey',
    'NM', 'New Mexico',
    'NY', 'New York',
    'NC', 'North Carolina',
    'ND', 'North Dakota',
    'OH', 'Ohio',
    'OK', 'Oklahoma',
    'OR', 'Oregon',
    'PW', 'Palau',
    'PA', 'Pennsylvania',
    'PR', 'Puerto Rico',
    'RI', 'Rhode Island',
    'SC', 'South Carolina',
    'SD', 'South Dakota',
    'TN', 'Tennessee',
    'TX', 'Texas',
    'UT', 'Utah',
    'VT', 'Vermont',
    'VI', 'Virgin Island',
    'VA', 'Virginia',
    'WA', 'Washington',
    'WV', 'West Virginia',
    'WI', 'Wisconsin',
    'WY', 'Wyoming'
]

ADDR_PATTERN = \
r'^(?P<address1>(\d{1,5}\s+(\w+\s*)+\s+(road|rd|parkway|pky|dr|drive|st|street|ln|la|lane|place|pl))|(P\.O\.\s+Box\s+\d{1,5}))\s*' +\
r'\s*,?\s*(?P<address2>(apt|bldg|dept|fl|floor|lot|pier|rm|room|slip|ste|suite|trlr|unit)\s+\w{1,5}\s*)?' +\
r',\s*(?P<city>([A-Z][a-z]+\s*){1,3}),\s*' +\
r'(?P<state>(' + '|'.join(STATE_NAMES) + ')\s*)' +\
r'(?P<zipcode>\d{5}(-\d{4})?)?$'

ADDRESS_REGEX = re.compile(ADDR_PATTERN, re.IGNORECASE)

MIN_KEYS = frozenset(['address1', 'city', 'state'])

def parse_address(address_string):
    m = ADDRESS_REGEX.match(address_string)
    result = {}
    if m is not None:
        for i in ('address1', 'address2', 'city', 'state', 'zipcode'):
            val = m.group(i)
            if val is not None:
                result[i] = val

    keys = frozenset([k for k in result.keys()])
    if (keys & MIN_KEYS) != MIN_KEYS:
        result = None

    return result
