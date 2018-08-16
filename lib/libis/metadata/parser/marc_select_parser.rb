require 'parslet'

require_relative 'basic_parser'
require_relative 'marc_rules'

module Libis
  module Metadata
    module Parser
      # noinspection RubyResolve

      # New style parsers and converters for metadata. New, not finished and untested.
      class MarcSelectParser < Libis::Metadata::Parser::BasicParser
        include Libis::Metadata::MarcRules
        root(:MARC)
        rule(:MARC) {str('MARC') >> spaces? >> tag.as(:tag) >> spaces? >> indicators >> spaces? >> subfield.maybe.as(:subfield)}

        # subfield
        # rule(:sf_condition) { sf_indicator >> sf_names >> (space >> sf_names).repeat }
        # rule(:sf_names) { sf_name.repeat(1) }
      end

    end
  end
end