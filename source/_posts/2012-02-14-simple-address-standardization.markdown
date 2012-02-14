---
layout: post
title: "Address Standardization in Ruby"
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

This article explores one way to solve that problem. I'll be using Ruby,
but the same approach works for other languages.

# The Approach

The simplest way to get started is to use REST-based mapping APIs already on
the Internet, such as Google Maps, Yahoo! Maps, Bing, and others. There are a
number of language-specific APIs available to make this task easier. For
example:

* Ruby: the [Ruby Geocoder gem](http://www.rubygeocoder.com/)
* Python: [googlemaps](http://pypi.python.org/pypi/googlemaps/)
* Java (and other JVM languages): [geocoder-java](http://code.google.com/p/geocoder-java/)

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
easiest way to do that is to hide write a very simple API of your own that
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

First, let's take a look at Ruby and Python implementations of the above API
specification, using Google Maps.

## Ruby

The Ruby Geocoder gem already handles all the heavy lifting for us, but there's
one wrinkle: If you give the gem a bad address, you'll still get data back, but
it'll be "zoomed out". For instance, here's the result of a search for a valid
address. (It happens to be Google's headquarters.)

. It returns an
array of matches; we'll just take the first one, and then extract its `data`
component, which contains the information we want.

Be sure to install the `geocoder` gem, or put it in your `Gemfile` if you're
using [Bundler](http://gembundler.com/).

{% codeblock Geocoder and Google Maps with Good Address lang:ruby %}
[1] pry(main)> require 'geocoder'
=> true
[2] pry(main)> result = Geocoder.search('1600 Amphitheatre Parkway, Mountain View, CA')
=> [#<Geocoder::Result::Google:0x00000002448868
  @data=
   {"address_components"=>
     [{"long_name"=>"1600", "short_name"=>"1600", "types"=>["street_number"]},
      {"long_name"=>"Amphitheatre Pkwy",
       "short_name"=>"Amphitheatre Pkwy",
       "types"=>["route"]},
      {"long_name"=>"Mountain View",
       "short_name"=>"Mountain View",
       "types"=>["locality", "political"]},
      {"long_name"=>"Santa Clara",
       "short_name"=>"Santa Clara",
       "types"=>["administrative_area_level_2", "political"]},
      {"long_name"=>"California",
       "short_name"=>"CA",
       "types"=>["administrative_area_level_1", "political"]},
      {"long_name"=>"United States",
       "short_name"=>"US",
       "types"=>["country", "political"]},
      {"long_name"=>"94043", "short_name"=>"94043", "types"=>["postal_code"]}],
    "formatted_address"=>
     "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    "geometry"=>
     {"location"=>{"lat"=>37.4211444, "lng"=>-122.0853032},
      "location_type"=>"ROOFTOP",
      "viewport"=>
       {"northeast"=>{"lat"=>37.4224933802915, "lng"=>-122.0839542197085},
        "southwest"=>{"lat"=>37.4197954197085, "lng"=>-122.0866521802915}}},
    "types"=>["street_address"]}>]
{% endcodeblock %}

Here's the result of searching for a nonexistent California address:

{% codeblock Geocoder and Google Maps with Bad Address lang:ruby %}
[3] pry(main)> result = Geocoder.search('1600 Curley Howard Parkway, Anytown, CA')
=> [#<Geocoder::Result::Google:0x00000002720680
  @data=
   {"address_components"=>
     [{"long_name"=>"California",
       "short_name"=>"CA",
       "types"=>["administrative_area_level_1", "political"]},
      {"long_name"=>"United States",
       "short_name"=>"US",
       "types"=>["country", "political"]}],
    "formatted_address"=>"California, USA",
    "geometry"=>
     {"bounds"=>
       {"northeast"=>{"lat"=>42.0095169, "lng"=>-114.131211},
        "southwest"=>{"lat"=>32.5342071, "lng"=>-124.4096195}},
      "location"=>{"lat"=>36.778261, "lng"=>-119.4179324},
      "location_type"=>"APPROXIMATE",
      "viewport"=>
       {"northeast"=>{"lat"=>41.2156363, "lng"=>-111.2221314},
        "southwest"=>{"lat"=>32.0683661, "lng"=>-127.6137334}}},
    "types"=>["administrative_area_level_1", "political"]}>]
{% endcodeblock %}

Note that with the valid address, we get back a "types" array (specifically,
`result[0].data["types"]`) that contains the string "street_address", meaning
that the result is granular to the street address. But with the second example,
we get "administrative_area_level_1", which is Google Maps-speak for "state",
in the U.S. In other words, the *geocoder* gem "zoomed out". This behavior
makes sense for geolocation, but it isn't very useful in an address normalizer.

Fortunately, it's relatively easy to correct this problem. The various "types"
values returned by the Google Maps API are documented at
<http://code.google.com/apis/maps/documentation/geocoding/#Types>. For our
purposes, if the top-level "types" value doesn't contain one of the following
values, then we can assume the address wasn't found.

* `street_address` indicates a precise street address, e.g., a house
* `subpremise` is a "first-order entity below a named location, usually a
  singular building within a collection of buildings with a common name." In
  practice, this is what Google Maps returns for addresses that contain, say,
  a suite number.

With that understanding, we can write our Ruby implementation:

{% include_code 2012-02-14-simple-address-standardization/normalize-google.rb %}

And here's a sample console run, with the valid and invalid addresses from
above.

{% codeblock Test Run lang:ruby %}
[1] pry(main)> require 'normalize-google'
=> true
[2] pry(main)> include AddressNormalizer
=> Object
[3] pry(main)> a = normalize_street_address '1600 Amphitheatre Parkway, Mountain View, CA'
=> #<AddressNormalizer::NormalizedAddress:0xd8e320>
[4] pry(main)> a.to_s
=> "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA"
[5] pry(main)> a = normalize_street_address '1600 Curley Howard Parkway, Anytown, CA'
=> nil
{% endcodeblock %}

## Python

For our Python implementation, we'll use the API directly, for maximum
flexibility. For example:

{% codeblock Python Google Maps with Good Address lang:python %}
$ ipython               
Python 2.7.1 (r271:86832, Mar 27 2011, 20:51:04) 
...
In [1]: import urllib

In [2]: s = '1600 Amphitheatre Parkway, Mountain View, CA'

In [3]: url = 'https://maps.googleapis.com/maps/api/geocode/json?address=%s&sensor=false' % urllib.quote(s)

In [4]: j = urllib.urlopen(url).read()

In [5]: import json

In [6]: h = json.loads(j)

In [7]: h
Out[7]: 
{u'results': [{u'address_components': [{u'long_name': u'California',
                                        u'short_name': u'CA',
                                        u'types': [u'administrative_area_level_1',
                                                   u'political']},
                                       {u'long_name': u'United States',
                                        u'short_name': u'US',
                                        u'types': [u'country',
                                                   u'political']}],
               u'formatted_address': u'California, USA',
               u'geometry': {u'bounds': {u'northeast': {u'lat': 42.0095169,
                                                        u'lng': -114.131211},
                                         u'southwest': {u'lat': 32.5342071,
                                                        u'lng': -124.4096195}},
                             u'location': {u'lat': 36.778261,
                                           u'lng': -119.4179324},
                             u'location_type': u'APPROXIMATE',
                             u'viewport': {u'northeast': {u'lat': 41.2156363,
                                                          u'lng': -111.2221314},
                                           u'southwest': {u'lat': 32.0683661,
                                                          u'lng': -127.6137334}}},
               u'types': [u'administrative_area_level_1', u'political']}],
 u'status': u'OK'}
{% endcodeblock %}

Note that the output is similar to what the Ruby `geocoder` gem produces. So,
the Python implementation is also similar.

{% include_code 2012-02-14-simple-address-standardization/normalize_google.py %}

Here's a sample console run, with the valid and invalid addresses from above.

{% codeblock Test Run lang:python %}
In [1]: from normalize_google import *

In [2]: a = normalize_street_address('1600 Amphitheatre Parkway, Mountain View, CA')

In [3]: str(a)
Out[3]: '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'

In [4]: a = normalize_street_address('1600 Curley Howard Parkway, Anytown, CA')

In [5]: print(a)
None
{% endcodeblock %}
