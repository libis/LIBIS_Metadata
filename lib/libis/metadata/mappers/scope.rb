# encoding: utf-8

require 'libis/metadata/dublin_core_record'
require 'libis/tools/assert'

module Libis
  module Metadata
    module Mappers
      # noinspection RubyResolve

      # Mixin for {::Libis::Metadata::DublinCoreRecord} to enable conversion of the Scope exported DC record.
      module Scope

        # Main conversion method.
        # @return [::Libis::Metadata::DublinCoreRecord]
        def to_dc
          assert(self.is_a? Libis::Metadata::DublinCoreRecord)

          doc = Libis::Metadata::DublinCoreRecord.new(self.to_xml)

          if doc.isPartOf

            # create new node for isReferencedBy
            new_node = doc.add_node(
                'isReferencedBy',
                doc.isPartOf.content,
                nil,
                'xsi:type' => 'dcterms:URI'
            )

            # Replace isPartOf with isReferencedBy
            doc.isPartOf.replace new_node

          end

          doc

        end

      end

    end
  end
end