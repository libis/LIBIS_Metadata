require_relative 'metadata/version'

module Libis
  module Metadata

    autoload :CommandLine, 'libis/metadata/command_line'
    autoload :Downloader, 'libis/metadata/downloader'

    autoload :MarcRecord, 'libis/metadata/marc_record'
    autoload :Marc21Record, 'libis/metadata/marc21_record'
    autoload :DublinCoreRecord, 'libis/metadata/dublin_core_record'

    # Mappers implementations for converting MARC records to Dublin Core.
    module Mappers

      autoload :Standard, 'libis/metadata/mappers/standard'
      autoload :Kuleuven, 'libis/metadata/mappers/kuleuven'
      autoload :Flandrica, 'libis/metadata/mappers/flandrica'
      autoload :Scope, 'libis/metadata/mappers/scope'

    end

  end
end

require_relative 'metadata/parsers'
