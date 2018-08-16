module Libis
  module Metadata
    module Parser

      autoload :BasicParser, 'libis/metadata/parser/basic_parser'
      autoload :DublinCoreParser, 'libis/metadata/parser/dublin_core_parser'
      autoload :Marc21Parser, 'libis/metadata/parser/marc21_parser'
      autoload :SubfieldCriteriaParser, 'libis/metadata/parser/subfield_criteria_parser'

    end
  end
end
