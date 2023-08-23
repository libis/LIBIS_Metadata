# encoding: utf-8

require 'libis/metadata/dublin_core_record'
require 'libis/tools/assert'

module Libis
  module Metadata
    module Mappers
      # noinspection RubyResolve

      # Mixin for {::Libis::Metadata::DublinCoreRecord} to enable conversion of the Scope exported DC record.
      module ScopeVlp

        # Main conversion method.
        # @return [::Libis::Metadata::DublinCoreRecord]
        def to_dc
          assert(self.is_a? Libis::Metadata::DublinCoreRecord)

          doc = Libis::Metadata::DublinCoreRecord.new(self.to_xml)

          # set isPartOf
          doc.isPartOf = doc.title.content

          # remove identifiers with URL
          doc.xpath('//dc:identifier[@xsi:type = "dcterms:URI"]').remove

          doc.title = ''

          doc
        end

      end

    end
  end
end