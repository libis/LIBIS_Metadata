[![Gem Version](https://badge.fury.io/rb/libis-metadata.svg)](http://badge.fury.io/rb/libis-metadata)
[![Build Status](https://travis-ci.org/Kris-LIBIS/LIBIS_Metadata.svg?branch=master)](https://travis-ci.org/Kris-LIBIS/LIBIS_Metadata)
[![Coverage Status](https://img.shields.io/coveralls/Kris-LIBIS/LIBIS_Metadata.svg)](https://coveralls.io/r/Kris-LIBIS/LIBIS_Metadata)
[![Dependency Status](https://gemnasium.com/Kris-LIBIS/LIBIS_Metadata.svg)](https://gemnasium.com/Kris-LIBIS/LIBIS_Metadata)

# Libis::Metadata

This gem contains classes and tools related to metadata. It depends on the libis-tools and libis-services gems.

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'libis-metadata'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libis-metadata

## Usage

In order to make available all the code the gem supplies a single file can be included:

```ruby
    require 'libis-metadata'
```

or:

```ruby
    require 'libis/metadata'
```

Alternatively, if you only want to use a single class or module, partial files are available. See the examples in the
sections below for their names.

## Content

This gem provides some modules and classes that assist in working with metadata. There are classes that allow to
create and/or read metadata for MARC(21), Dublin Core and SharePoint. These classes all live in the
Libis::Metadata namespace. Additionally there are parsers and converters in the Libis::Metadata::Parser namespace

### MARC

The classes {::Libis::Metadata::MarcRecord} and it's child class {::Libis::Metadata::Marc21Record} are
mainly built for reading MARC(21) records. Most of the class logic is in the base class
{::Libis::Metadata::MarcRecord MarcRecord}, which is incomplete and should be considered an abstract class.

{::Libis::Metadata::Marc21Record Marc21Record} on the other hand only contains the logic to parse the XML data
into the internal structure. A {::Libis::Metadata::MarcRecord MarcRecord} is created by supplying it an XML node
(from Nokogiri or {::Libis::Tools::XmlDocument}) that contains child nodes with the MARC data of a single record.

The code will strip namespaces from the input in order to greatly simplify working with the XML.

### Dublin Core

The {Libis::Metadata::DublinCoreRecord} class is an extension of the {Libis::Tools::XmlDocument} class with specific
enhancements to support both dc: and dc_terms: namespaces. Creating a new object from scratch will automatically include
the proper xmlns references and a dc:record root element. When adding nodes without namespace prefix, the class will
add the proper namespace for you, prefering dc: over dc_terms in case of ambiguity.

### Mappers



## Contributing

1. Fork it ( https://github.com/Kris-LIBIS/LIBIS_Metadata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
