---
layout: post
title: "Simple Address Standardization"
date: 2012-02-14 17:58
comments: true
categories: [programming, address standardization, geocoding, ruby]
toc: true
---

# Introduction

Suppose you're writing an application that stores and compares street
addresses. Depending on how you obtain those addresses, you may need to
standardize them.

* Standardizing the addresses makes them easier to compare.
* Standardizing the address can have the side effect of validating the
  address.
* Standardizing an address also makes it more likely that you can send a
  physical piece of mail to the address and have it actually arrive.

This article explores one way to solve that problem. I'll be showing examples
of Ruby and Python, but the same general approach works for other languages.

<!-- more -->

# The Approach

The simplest way to get started is to use REST-based mapping APIs already on
the Internet, such as Google Maps, Yahoo! Maps, Bing, and others. There are a
number of language-specific APIs available to make this task easier. For
example:

* Ruby: the [Ruby Geocoder][] gem
* Python: [py-googlemaps][]
* Java (and other JVM languages): [geocoder-java][]

**Note**: The Internet-based mapping APIs all have restrictions. The Google
Maps API, for instance, contains this clause in its
[terms of service](http://code.google.com/apis/maps/terms.html):

{% blockquote Google, Inc. http://code.google.com/apis/maps/terms.html Google Maps Terms of Service (Excerpt) %}
&#167; 10.1.1(g) No Use of Content without a Google Map. You must not use or display the Content without a corresponding Google map, unless you are explicitly permitted to do so in the Maps APIs Documentation, or through written permission from Google. For example, you must not use geocodes obtained through the Service except in conjunction with a Google map, but you may display Street View imagery without a corresponding Google map because the Maps APIs Documentation explicitly permits you to do so.
{% endblockquote %}

If you're developing an application that only needs to do address normalization
and geocoding, but won't be displaying a map, these services are not suitable
for production. You may be able to get away with using them during development
(since your web site won't be publicly accessible), though that's really a
question for your lawyer.

Let's assume, however, that you've determined (by discussing it with your
lawyer or by calling Google or Yahoo!) that it's safe to use one of the
Internet mapping services, but you also want to be able to move to a commercial
service down the road. (See below for some possible commercial services.) The
easiest way to do that is to write a very simple API of your own that
hides the underlying address normalization API you're using.

# API Specification

To hide the underlying API being used (making it easier to switch to a
different implementation, when necessary), let's first define a higher-level
API of our own.

Requirements:

* Provide a generic `NormalizedAddress` object that contains the fields we
  need.
* Provide a function or class that takes a raw address and returns a
  `NormalizedAddress` object.

## Ruby

The Ruby specification for our API will look like the following. (There are,
obviously, other ways to cast this API.)

{% codeblock Ruby API lang:ruby %}
module AddressNormalizer
  class NormalizedAddress
    attr_reader :address_line1, :address_line2, :city, :state_province,
                :postal_code, :country, :latitude, :longitude

    def initialize(...)
      @address_line1  = ...
      @address_line2  = ...
      @city           = ...
      @state_province = ...
      @postal_code    = ...
      @country        = ...
      @latitude       = ...
      @longitude      = ...
    end
  end

  def normalize_street_address(raw_address_string)
     ...
  end
end
{% endcodeblock %}

## Python

The Python specification for our API is similar.

{% codeblock Python API lang:python %}
class NormalizedAddress(object):
    def __init__(self, ... ):
        self.address_line1  = ...
        self.address_line2  = ...
        self.city           = ...
        self.state_province = ...
        self.postal_code    = ...
        self.country        = ...
        self.latitude       = ...
        self.longitude      = ...

def normalize_street_address(raw_address_string):
    ...
{% endcodeblock %}

# Google Maps Implementation

## Implementation Issues

Before diving into the implementations, themselves, there are several problems
we have to address (pun intended).

### The Maps API doesn't truly standardize addresses

The free services do not always standardize U.S. addresses properly--at least,
not from the United States Postal Service's standpoint. In the U.S., many towns
often share post offices. For instance, consider the address of an office
where I used to work:

1400 Liberty Ridge Drive, Chesterbrook, PA

The post office serving this address is actually Wayne, PA. The
standardized address is:

1400 Liberty Ridge Dr, Wayne, PA 19087

Let's use the Ruby `geocoder` gem to see what Google returns for the first
address:

{% codeblock lang:ruby %}
$ pry
[1] pry(main)> require 'geocoder'
=> true
[2] pry(main) res = Geocoder.search('1400 Liberty Ridge Drive, Chesterbrook, PA')
=> [#<Geocoder::Result::Google:0x00000000cfa788
  @data=
...
[3] res[0].formatted_address
=> "1400 Liberty Ridge Dr, Chesterbrook, PA 19087, USA"
{% endcodeblock %}

Note that the town name has not been standardized to the correct post office
name. The Yahoo! Maps API exhibits similar behavior.

If you're comparing many different addresses, you might need to ensure that
they all use the canonical post office name. If you're willing to
make another connection to Google, you can try to correct this problem by
taking the returned latitude and longitude values and _reverse geocoding_
them:

{% codeblock lang:ruby %}
[3] pry(main) latitude = results[0].data["geometry"]["location"]["lat"]
=> 40.228934
[4] pry(main) longitude = results[0].data["geometry"]["location"]["lng"]
=> -75.517588
[5] res = Geocoder.search(latitude=latitude, longitude=longitude)
=> [#<Geocoder::Result::Google:0x00000000cfa788
  @data=
  ...

[6] res[0].foramtted_address
=> "1400 Liberty Ridge Dr, Wayne, PA 19087, USA"
{% endcodeblock %}

This solution doesn't work with _every_ address. (It doesn't work with my home
address, for instance). However, it's still worth trying.

### The Maps API can "zoom out" if the address isn't valid

If you give the Google Maps API a bad address, you can either get no data or "zoomed out" data. For instance, here's what you get for the nonsense address
"100 My Place, Foobar, XY".

{% codeblock lang:ruby %}
[1] pry(main)> require 'geocoder'
=> true
[2] pry(main) results = Geocoder.search('100 My Place, Foobar, XY')
=> []
{% endcodeblock %}

Bad address = no results. That makes sense: There's no such state as "XY". But,
if I give the API a bad address _with_ a valid state, I get "zoomed out"
results:

{% codeblock lang:ruby %}
[2] pry(main) results = Geocoder.search('100 My Place, Foobar, PA')
=> [#<Geocoder::Result::Google:0x00000001083468
  @data=
   {"address_components"=>
     [{"long_name"=>"Pennsylvania",
       "short_name"=>"PA",
       "types"=>["administrative_area_level_1", "political"]},
      {"long_name"=>"United States",
       "short_name"=>"US",
       "types"=>["country", "political"]}],
    "formatted_address"=>"Pennsylvania, USA",
    "geometry"=>
     {"bounds"=>
       {"northeast"=>{"lat"=>42.26936509999999, "lng"=>-74.6895019},
        "southwest"=>{"lat"=>39.7197989, "lng"=>-80.5198949}},
      "location"=>{"lat"=>41.2033216, "lng"=>-77.1945247},
      "location_type"=>"APPROXIMATE",
      "viewport"=>
       {"northeast"=>{"lat"=>42.2690472, "lng"=>-75.1455745},
        "southwest"=>{"lat"=>40.11995350000001, "lng"=>-79.2434749}}},
    "types"=>["administrative_area_level_1", "political"]}>]
{% endcodeblock %}

Note that with the valid address, we get back a "types" array (specifically,
`result[0].data["types"]`) that contains the string "street_address", meaning
that the result is granular to the street address. But with the second example,
we get "administrative_area_level_1", which is Google Maps-speak for "state",
in the U.S. In other words, the Maps API zoomed out to the nearest geographical
designation it could identify--which, in this case, was the state of
Pennsylvania. 

This behavior makes sense for geolocation, but it isn't very useful in an
address normalizer.

Fortunately, it's relatively easy to correct this problem. The various "types"
values returned by the Google Maps API are documented at
<http://code.google.com/apis/maps/documentation/geocoding/#Types>. For our
purposes, if the top-level "types" value doesn't contain one of the following
values, then we can assume the address wasn't found:

* `street_address` indicates a precise street address, e.g., a house
* `subpremise` is a "first-order entity below a named location, usually a
  singular building within a collection of buildings with a common name." In
  practice, this is what Google Maps returns for addresses that contain, say,
  a suite number.

## The Code

Now we're ready to write some code.

### Ruby Google Maps Implementation

The Ruby Geocoder gem handles connecting to the Google Maps REST service,
retrieving the JSON results, and decoding the JSON. So, let's use it and save
ourselves a little work. Note, however, that we still have to decode the
results, mapping the Google Maps-specific data encoding into our more
generic `NormalizedAddress` object.

{% include_code Normalize Address via Google Maps, in Ruby 2012-02-14-simple-address-standardization/normalize_google.rb %}

Here's a sample console run, with a valid address (Google headquarters) and
invalid addresses (the Foobar, Pennsylvania, example from above):

{% codeblock Test Run lang:ruby %}
[1] pry(main)> require 'normalize_google'
=> true
[2] pry(main)> include AddressNormalizer
=> Object
[3] pry(main)> a = normalize_street_address '1600 Amphitheatre Parkway, Mountain View, CA'
=> #<AddressNormalizer::NormalizedAddress:0xd8e320>
[4] pry(main)> a.to_s
=> "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA"
[5] pry(main)> a = normalize_street_address '100 My Place, Foobar, PA'
=> nil
{% endcodeblock %}

### Python Google Maps Implementation

For our Python implementation, we'll use the [py-googlemaps][] API. The
results are somewhat different from the Ruby `geocoder` gem. For example:

{% codeblock Python Google Maps with Good Address lang:python %}
$ ipython               
Python 2.7.1 (r271:86832, Mar 27 2011, 20:51:04) 
...
In [1]: from googlemaps import GoogleMaps

In [2]: g = GoogleMaps()

In [3]: d = g.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

In [4]: d  # reformatted slightly, for readability
Out [4]:
{
  u'Status': {
      u'code': 200,
      u'request': u'geocode'
  },
  u'Placemark': [{
    u'Point': {
      u'coordinates': [-122.0853032, 37.4211444, 0]
    }, 
    u'ExtendedData': {
      u'LatLonBox': {
        u'west': -122.0866522,
        u'east': -122.0839542,
        u'north': 37.4224934,
        u'south': 37.4197954}
      },
      u'AddressDetails': {
        u'Country': {
          u'CountryName': u'USA',
          u'AdministrativeArea': {
            u'AdministrativeAreaName': u'CA',
            u'Locality': {
              u'PostalCode': {u'PostalCodeNumber': u'94043'},
              u'Thoroughfare': {
                u'ThoroughfareName': u'1600 Amphitheatre Pkwy'
              }, 
              u'LocalityName': u'Mountain View'
            }
          },
          u'CountryNameCode': u'US'
        },
        u'Accuracy': 8
      },  
      u'id': u'p1',
      u'address': u'1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
  }], 
  u'name': u'1600 Amphitheatre Parkway, Mountain View, CA'
}
{% endcodeblock %}

For a non-existent address that zooms out ("100 My Place, Foobar, PA"),
here's the result:

{% codeblock lang:python %}
In [5]: d = g.geocode('100 My Place, Foobar, PA')

In [6]: d  # reformatted slightly, for readability
Out [6]:
{
  u'Status': {u'code': 200, u'request': u'geocode'}, 
  u'Placemark': [{
    u'Point': {
      u'coordinates': [-77.1945247, 41.2033216, 0]
    },
    u'ExtendedData': {
      u'LatLonBox': {
        u'west': -79.2434749, 
        u'east': -75.1455745,
        u'north': 42.2690472,
        u'south': 40.1199535
      }
    },
    u'AddressDetails': {
      u'Country': {
        u'CountryName': u'USA',
        u'AdministrativeArea': {
          u'AdministrativeAreaName': u'PA'
        },
        u'CountryNameCode': u'US'
      },
      u'Accuracy': 2
    },
    u'id': u'p1',
    u'address': u'Pennsylvania, USA'
  }],
  u'name': u'100 My Place, Foobar, PA'
}
{% endcodeblock %}

For a completely nonexistent address ("100 My Place, Foobar, XY"), the API
raises an exception:
{% codeblock lang:python %}
In [7]: d = g.geocode('100 My Place, Foobar, PA')
GoogleMapsError                           Traceback (most recent call last)

/home/bmc/<ipython console> in <module>()

/home/bmc/.pythonbrew/pythons/Python-2.7.1/lib/python2.7/site-packages/googlemaps.pyc in geocode(self, query, sensor, oe, ll, spn, gl)
    260         status_code = response['Status']['code']
    261         if status_code != STATUS_OK:
--> 262             raise GoogleMapsError(status_code, url, response)
    263         return response
    264 

GoogleMapsError: Error 602: G_GEO_UNKNOWN_ADDRESS
{% endcodeblock %}

The documentation for the API shows this example:

{% codeblock lang:python %}
gmaps = GoogleMaps(api_key)
address = '350 Fifth Avenue New York, NY'
result = gmaps.geocode(address)
placemark = result['Placemark'][0]
lng, lat = placemark['Point']['coordinates'][0:2]    # Note these are backkwards from usual
print lat, lng
6721118 -73.9838823
details = placemark['AddressDetails']['Country']['AdministrativeArea']
street = details['Locality']['Thoroughfare']['ThoroughfareName']
city = details['Locality']['LocalityName']
state = details['AdministrativeAreaName']
zipcode = details['Locality']['PostalCode']['PostalCodeNumber']
print ', '.join((street, city, state, zipcode))
350 5th Ave, Brooklyn, NY, 11215
{% endcodeblock %}

It seems reasonable to adopt this strategy:

* If we get an exception, we have a bad address.
* If we can't find `details['Locality']['PostalCode']['PostalCodeNumber']`
  in the results, then the address isn't granular enough, so treat it as a
  bad address.

Unfortunately, reverse-geocoding, with this Python API, doesn't always return
useful information, so that step is omitted here.

{% include_code Normalize Address via Google Maps, in Python 2012-02-14-simple-address-standardization/normalize_google.py %}

Here's a sample console run, with the same addresses as above:

{% codeblock Test Run lang:python %}
In [1]: from normalize_google import *

In [2]: a = normalize_street_address('1600 Amphitheatre Parkway, Mountain View, CA')

In [3]: a
Out[3]: {'address_line2': None, 'city': u'Mountain View', 'address_line1': u'1600 Amphitheatre Pkwy', 'state_province': u'CA', 'longitude': -122.0853032, 'postal_code': u'94043', 'country': u'USA', 'latitude': 37.4211444, 'formatted_address': u'1600 Amphitheatre Pkwy Mountain View CA 94043 USA'}

In [4]: str(a)
Out[4]: '1600 Amphitheatre Pkwy Mountain View CA 94043 USA'

In [5]: a = normalize_street_address('100 My Place, Foobar, PA')

In [6]: print(a)
None

In [7]: a = normalize_street_address('100 My Place, Foobar, ZZ')

In [8]: print(a)
None
{% endcodeblock %}

# Using a Commercial Service

You've completed your initial development, and you're ready to launch. But,
your slick new service will not be displaying maps, and your lawyer has
told you, in no uncertain terms, that you cannot risk using Google Maps (or
Yahoo! Maps) in violation of the terms of service. So, it's time to switch
to a commercial service.

Fortunately, the API is designed to hide its reliance on Google Maps from the
outside world, so reimplementing it should be easy. There are a number of
commercial solutions that provide REST APIs, and many are reasonably priced.
Here are three examples:

* [Melissa Data][] provides both address verification and geocoding solutions.
  Its [Address Verifier][] service provides a REST API and supports U.S,
  Canadian, and international addresses. Their subscription plans are based on
  yearly volume.
* [AddressDoctor][] provides a SOAP API for scrubbing addresses. Their plans
  are also based on yearly volume.
* [SmartyStreets][] provides a REST API, and with monthly or yearly 
  volume-based subscription plans. In addition, they have a free plan that
  allows 250 addresses to be scrubbed a month, and they have a
  [GitHub repository][SmartyStreets-Github] that contains sample code 
  for Java, Python, C#, Ruby and Javascript.

Another option is [Gisgraphy][]. Gisgraphy is an open source geocoding
product, which you can download and run locally. If you want to use the
REST API on their server, they have a premium service; however, hosting the
data locally, providing your own REST service, appears to be free. Of course,
if you use this solution, you're responsible for keeping the software and the
data up-to-date, as well as providing a local server to run the software.

Let's reimplement our service in terms of SmartyStreets. There are a few
caveats to note:

1. The SmartyStreets LiveAddress API does not do geocoding, so we won't
   get latitude and longitude out of our queries. We'll leave those fields
   empty in our API.
2. The API requires pre-parsed addresses; it does not handle a single address
   string. That means we'll have to figure out how to parse the address string
   ourselves.
3. The resulting changes will be US-specific.

{% update %}
**Update (4 August, 2012)** Per a comment (see below), SmartyStreets now
provides both geocoding and single-string address parsing, so caveats #1 
and #2, above, no longer apply.
{% endupdate %}

## Ruby SmartyStreets Implementation

Let's start with Ruby. Parsing the address is not a big deal in Ruby, because
we can use the [StreetAddress][] gem. The gem is fully documented at
<http://streetaddress.rubyforge.com>.

{% codeblock lang:bash %}
$ gem install StreetAddress
{% endcodeblock %}

The SmartyStreets JSON REST API is documented at
<http://wiki.smartystreets.com/liveaddress_api_users_guide#section-4rest-json-endpoint>, though several fields are missing from the documentation. Like many
such APIs, it'll return multiple possible choices for an address. In this
implementation, we're just going to take the first one. However, for
interactive services, where you're scrubbing a user-supplied address, if there
are several possible hits, you may want to display them and allow the user to
choose which one seems like the right address.

The Ruby reimplementation of our address normalizer API is fairly
straightforward:

{% include_code Normalize Address via SmartyStreets, in Ruby 2012-02-14-simple-address-standardization/normalize_smartystreets.rb %}

Before you can actually use that software, you have to register with
SmartyStreets, get an API key, and plug it into the code by setting the
`API_KEY` constant.

Here's a sample console run.

{% codeblock Test Run lang:ruby %}
[1] pry(main)> require 'normalize_smartypants'
=> true
[2] pry(main)> include AddressNormalizer
=> Object
[3] pry(main)> a = normalize_street_address '1600 Amphitheatre Parkway, Mountain View, CA'
=> #<AddressNormalizer::NormalizedAddress:0xd8e320>
[4] pry(main)> a.to_s
=> "1600 Amphitheatre Pkwy, Mountain View, CA 94043-1351"
[5] pry(main)> a = normalize_street_address '100 My Place, Foobar, PA'
=> nil
{% endcodeblock %}

## Python SmartyStreets Implementation

The reimplementation in Python is similar. However, there isn't a handy Python
library for parsing a single-string address. I've put together a quick hack,
for the purposes of this blog post. 

**WARNING:** This hack is _not_ suitable for production use! It is far from
robust and will fail on some addresses. It exists here solely for demonstration
purposes. A better solution would be to port the Ruby [StreetAddress][] gem to
Python.

With that warning out of the way, here's the address parsing code:

{% include_code Quick and Dirty Address Parser, in Python 2012-02-14-simple-address-standardization/parse_addr.py %}

Now that we have an address parser, however brittle, we can write the Python
version of the SmartyStreets implementation.

{% include_code Normalize Address via SmartyStreets, in Ruby 2012-02-14-simple-address-standardization/normalize_smartystreets.py %}

And here's the obligatory console test run:

{% codeblock Test Run lang:python %}
In [1]: from normalize_google import *

In [2]: a = normalize_street_address('1600 Amphitheatre Parkway, Mountain View, CA')

In [3]: a
Out[3]: {'address_line2': '', 'city': u'Mountain View', 'address_line1': u'1600 Amphitheatre Pkwy', 'state_province': u'CA', 'longitude': None, 'postal_code': u'94043 1351', 'country': 'US', 'latitude': None, 'formatted_address': u'1600 Amphitheatre Pkwy, Mountain View, CA 94043 1351'}

In [4]: str(a)
Out[4]: '1600 Amphitheatre Pkwy, Mountain View, CA 94043 1351'

In [5]: a = normalize_street_address('100 My Place, Foobar, PA')

In [6]: print(a)
None

In [7]: a = normalize_street_address('100 My Place, Foobar, ZZ')

In [8]: print(a)
None
{% endcodeblock %}

# Further Enhancements

An even better implementation would be to keep both the SmartyStreets _and_
Google implementations, allowing either one to be selected by a constant,
a configuration parameter, or an environment variable. Since this task isn't
a difficult enhancement, it's left as an exercise for the reader.

# References

* [Melissa Data][]'s [Address Verifier][]
* [AddressDoctor][]
* [SmartyStreets][]
* [Python Googlemaps API][py-googlemaps]
* [Ruby StreetAddress][StreetAddress] gem
* [Ruby Geocoder][] gem
* [geocoder-java][] library

[Melissa Data]: http://www.melissadata.com/
[Address Verifier]: http://www.melissadata.com/address-verification/index.htm
[AddressDoctor]: http://www.addressdoctor.com/
[SmartyStreets]: http://www.smartystreets.com/
[SmartyStreets-Github]: https://github.com/smartystreets/LiveAddressSamples
[py-googlemaps]: http://py-googlemaps.sourceforge.net/
[StreetAddress]: http://streetaddress.rubyforge.com
[Ruby Geocoder]: http://www.rubygeocoder.com/
[geocoder-java]: http://code.google.com/p/geocoder-java/
[Gisgraphy]: http://www.gisgraphy.com/
