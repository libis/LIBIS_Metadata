# encoding: utf-8
require_relative 'spec_helper'
require 'libis/metadata/mapper'
require 'libis//metadata/parsers'
require 'parslet'
require 'parslet/convenience'
require 'pp'

$DEBUG = false

RSpec.describe 'Metadata Mapper' do

  subject(:mapper) { Libis::Metadata::Mapper.new(
      Libis::Metadata::Parser::Marc21Parser.new,
      Libis::Metadata::Parser::DublinCoreParser.new,
      Libis::Metadata::Parser::Marc21Parser.new,
      File.join(File.dirname(__FILE__), 'data', 'MetadataMapping.xlsx')) }

  it 'Initialization' do
    expect(mapper).to_not be_nil
  end

end