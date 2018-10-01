require 'uri'
require 'pathname'
require 'awesome_print'

require 'libis/services/alma/sru_service'
require 'libis/services/scope/search'

require 'libis/tools/xml_document'
require 'libis/tools/extend/string'

require 'libis/metadata/marc21_record'
require 'libis/metadata/dublin_core_record'

require 'libis/metadata/mappers/kuleuven'
require 'libis/metadata/mappers/scope'

module Libis
  module Metadata

    class Downloader
      attr_reader :service, :mapper_class, :config

      def initialize
        @service = nil
        @target_dir = nil
        @config = nil
        @mapper_class = nil
      end

      def configure(config)
        metadata = config[:metadata]
        case metadata
        when 'alma'
          @service ||= Libis::Services::Alma::SruService.new
          @mapper_class = Libis::Metadata::Mappers::Kuleuven
        when 'scope'
          @service = ::Libis::Services::Scope::Search.new
          @mapper_class = Libis::Metadata::Mappers::Scope
          @service.connect(config[:password], config[:password], config[:database])
        else
          raise RuntimeError, "Service '#{service}' unknown"
        end
        @target_dir = config[:target_dir]
        @config = config
      rescue Exception => e
        raise RuntimeError "failed to configure metadata service: #{e.message} @ #{e.backtrace.first}"
      end

      def download(term, filename, pid = nil)
        record = search(term)
        return nil unless record

        record = md_update_xml(pid, record) if pid

        record.save File.join(@target_dir, filename)

        filename
      end

      # @return [Libis::Metadata::DublinCoreRecord]
      def search(term)
        record = case service
                 when ::Libis::Services::Alma::SruService
                   result = service.search(config[:field], URI::encode("\"#{term}\""), config[:library])
                   raise RuntimeError "Multiple records found for #{config[:field]}=#{term}" if result.size > 1
                   result.empty? ? nil : ::Libis::Metadata::Marc21Record.new(result.first.root)

                 when ::Libis::Services::Scope::Search
                   service.query(term, type: config[:field])
                   service.next_record do |doc|
                     ::Libis::Metadata::DublinCoreRecord.new(doc.to_xml)
                   end

                 else
                   raise RuntimeError "Service '#{service}' unknown"

                 end

        unless record
          raise RuntimeError, "No record found for #{config[:field]} = '#{term}'"
        end

        record.extend mapper_class
        record.to_dc

      rescue Exception => e
        raise RuntimeError, "Search request failed: #{e.message}"
      end

      def save(record, filename)
        return false unless record

        record.save File.join(@target_dir, filename)

        true
      end

      NO_DECL = Nokogiri::XML::Node::SaveOptions::FORMAT + Nokogiri::XML::Node::SaveOptions::NO_DECLARATION

      def md_update_xml(pid, record)
        Libis::Tools::XmlDocument.parse <<EO_XML
<updateMD xmlns="http://com/exlibris/digitool/repository/api/xmlbeans">
  <PID>#{pid}</PID>
  <metadata>
    <type>descriptive</type>
    <subType>dc</subType>
    <content>
      <![CDATA[#{record.document.to_xml(save_with: NO_DECL)}]]>
    </content>
  </metadata>
</updateMD>
EO_XML
      end

    end

  end
end