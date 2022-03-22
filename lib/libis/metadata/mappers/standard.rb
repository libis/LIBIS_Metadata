# encoding: utf-8

require 'libis/metadata/marc_record'
require 'libis/metadata/dublin_core_record'
require 'libis/tools/assert'

module Libis
  module Metadata
    module Mappers
      # noinspection RubyResolve

      # Mixin for {::Libis::Metadata::MarcRecord} to enable conversion into
      # {Libis::Metadata::DublinCoreRecord}. This module implements the standard mapping for KU Leuven.
      module Standard

        # Main conversion method.
        # @param [String] label optional extra identified to add to the DC record.
        # @return [::Libis::Metadata::DublinCoreRecord]
        def to_dc(label = nil)
          assert(self.is_a? Libis::Metadata::MarcRecord)

          doc = Libis::Metadata::DublinCoreRecord.new do |xml|
            marc2dc_identifier(xml, label)
            marc2dc_title(xml)
            marc2dc_medium(xml)
            marc2dc_rights(xml)
            marc2dc_type(xml)
            marc2dc_source(xml)
          end

          # deduplicate the XML
          found = Set.new
          doc.root.children.each {|node| node.unlink unless found.add?(node.to_xml)}

          doc

        end

        protected

        def marc2dc_identifier(xml, label = nil)
          # DC:IDENTIFIER
          marc2dc_identifier_label(label, xml)
          marc2dc_identifier_001(xml)
        end

        def marc2dc_title(xml)
          # DC:TITLE
          marc2dc_title_245(xml)
        end

        def marc2dc_medium(xml)
          # DCTERMS:MEDIUM
          marc2dc_medium_340(xml)
        end

        def marc2dc_rights(xml)
          # DC:RIGHTS
          marc2dc_rights_542(xml)
        end

        def marc2dc_type(xml)
          # DC:TYPE
          marc2dc_type_653__6_a(xml)
        end

        def marc2dc_source(xml)
          # DC: SOURCE
          marc2dc_source_8528_(xml)
        end

        private

        def marc2dc_identifier_label(label, xml)
          # noinspection RubyResolve
          xml['dc'].identifier label if label
        end

        def marc2dc_identifier_001(xml)
          # "urn:ControlNumber:" [MARC 001]
          all_tags('001') { |t|
            xml['dc'].identifier(element(t.datas, prefix: 'urn:ControlNumber:'), 'xsi:type' => 'dcterms:URI')
          }
        end

        def marc2dc_title_245(xml)
          all_tags('245', 'a b') { |t|
            xml['dc'].title(element(t._ab, join: ' : '))
          }
        end

        def marc2dc_medium_340(xml)
          # [MARC 340 ## $a $e]
          all_tags('340', 'a e') { |t|
            xml['dcterms'].medium list_s(t._ae)
          }
        end

        def marc2dc_rights_542(xml)
          # [MARC 542 ## $l / $n [$u]]
          all_tags('542') { |t|
            xml['dc'].rights list_s(element(t._ln, join: ' / '), element(t._u, fix: '[]'))
          }
        end

        def marc2dc_type_653__6_a(xml)
          # [MARC 653 #6 $a]
          each_field('653#6', 'a') { |f| xml['dc'].type f }
        end

        def marc2dc_source_8528_(xml)
          # [MARC 852 8_ $b $c, $h]
          # first_tag('852', 'bch') { |t|
            # xml['dc'].source list_c(element(t._bc, join(' '), t._h)
          # }
        end

      end

    end
  end
end