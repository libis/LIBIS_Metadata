require_relative 'spec_helper'
require 'libis/tools'

require 'rspec/matchers'
require 'equivalent-xml'

require 'awesome_print'

INPUT=%w'IE11156303 IE16278391 IE16423797'

RSpec.describe 'StandardMapper' do

  let(:input) { File.join(File.dirname(__FILE__), '8389207.marc')}
  let(:output) { File.join(File.dirname(__FILE__), '8389207_standard.dc')}

  it 'Correct Standard conversion' do

    INPUT.each do |name|
      xml_in = Libis::Tools::XmlDocument.open(File.join(File.dirname(__FILE__), "#{name}.marc"))
      input = Libis::Metadata::Marc21Record.new(xml_in.root)
      expect(input).to be_a Libis::Metadata::Marc21Record

      output = Libis::Metadata::DublinCoreRecord.new(File.join(File.dirname(__FILE__), "#{name}.dc"))
      expect(output).to be_a Libis::Metadata::DublinCoreRecord

      input.extend Libis::Metadata::Mappers::Standard
      converted = input.to_dc
      expect(converted).to be_a Libis::Metadata::DublinCoreRecord

      converted.root.elements.each_with_index do |element, i|
        expect(element).to be_equivalent_to(output.root.elements[i])
      end

    end

  end
end
