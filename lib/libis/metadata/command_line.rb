require 'thor'
require 'tty-prompt'

require 'libis/metadata/downloader'
require 'libis/tools/extend/hash'

require 'libis/metadata/cli/cli_helper'
require 'libis/metadata/cli/cli_downloader'

module Libis
  module Metadata

    class CommandLine < Thor

      include Cli::Helper
      include Cli::Downloader

      def download(*terms)
        super
      end

    end

  end
end
