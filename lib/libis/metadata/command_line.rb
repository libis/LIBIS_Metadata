require 'thor'
require 'tty-prompt'

require 'libis/metadata/downloader'
require 'libis/tools/extend/hash'

module Libis
  module Metadata

    class CommandLine < Thor

      def self.exit_on_failure?
        true
      end

      # noinspection RubyStringKeysInHashInspection
      VALID_SOURCES = {
          'alma' => %w'alma.mms_id alma.local_field_983',
          'scope' => %w'ID REPCODE'
      }

      attr_reader :prompt

      def initialize(*args)
        @prompt = TTY::Prompt.new
        super
      end

      desc 'download [options] [TERM[:PID] ...]', 'Download metadata'
      long_desc <<-DESC
      
      'download [TERM[:PID] ...]' will download metadata from Alma or Scope.

      The output format can either be Dublin Core or a Rosetta MD Update file. If you supply a Rosetta IE PID
      the tool will generate a Rosetta MD Update file, a regular Dublin Core XML file if you don't. Note that
      there is no check if the IE PID is a valid one.

      The list of search terms will be processed automatically. If there are no terms supplied on the command-
      line, the program will ask for terms until you supply an empty term. A search term can be appended with
      a ':' and a PID in which case the program will create Rosetta MD Update XML files for each term found.
      Otherwise, Dublin Core XML files will be generated.

      For any option that is not supplied on the command line and doesn't have a default value, the tool will 
      ask you interactively to supply a value.  

      DESC

      method_option :quiet, aliases: '-q', desc: 'Do not ask for options that have a default value',
                    type: :boolean, default: false
      method_option :source, aliases: '-s', banner: 'metadata_source', desc: 'Metadata source system',
                    default: VALID_SOURCES.keys.first, enum: VALID_SOURCES.keys
      method_option :field, aliases: '-f', banner: 'field_name', desc: 'Search field in the Metadata system;' +
          ' default value depends on selected metadata source system: ' +
          VALID_SOURCES.map {|k, v| "#{k}: #{v.first}"}.join(', '),
                    enum: VALID_SOURCES.values.flatten
      method_option :library, aliases: '-l', banner: 'library_code', desc: 'Library code for Alma',
                    default: '32KUL_KUL'
      method_option :database, aliases: '-d', desc: 'Scope database to connect to'
      method_option :user, aliases: '-u', desc: 'Database user name'
      method_option :password, aliases: '-p', desc: 'Database password'
      method_option :target_dir, aliases: '-t', desc: 'Directory where files will be created', default: '.'

      def download(*terms)

        unless Dir.exist?(options.target_dir)
          prompt.error "ERROR: target directory '#{options.target_dir}' does not exist"
          exit -1
        end

        md = Libis::Metadata::Downloader.new

        config = download_configure

        md.configure config

        if terms.empty?
          while (term = prompt.ask 'Search value (return to stop) :')
            pid = prompt.ask 'IE PID to update (leave empty to only download the DC record) :'
            filename = prompt.ask('File name: ', default: "#{pid || term}.xml")
            md.download(term, filename, pid)
          end
        else
          terms.each do |t|
            term, pid = t.split(':')
            filename = "#{pid || term}.xml"
            md.download(term, filename, pid)
          end
        end
      end

      protected

      def download_configure
        result = options.quiet ? options.key_strings_to_symbols : {}

        ask 'Metadata source', result, :source, default: options.source, enum: VALID_SOURCES.keys
        # Set appropriate default for field depending on source selection
        result[:field] = VALID_SOURCES[result[:source]].first if result[:source] && !result[:field]
        ask 'Search field', result, :field, default: options.field, enum: VALID_SOURCES[result[:source]]
        case result[:source]
        when 'alma'
          ask 'Library code', result, :library, default: options.library
        when 'scope'
          ask 'Database name', result, :database, default: options.database
          ask 'User name', result, :user, default: options.user
          ask 'Password', result, :password, default: options.password, mask: true
        else
          # Other source
        end
        result[:target_dir] = tree_select(options.target_dir, question: 'target directory') unless result[:target_dir]

        result
      end

      private

      def index_of(list, value)
        i = list.index(value)
        i += 1 if i
        i
      end

      def ask(question, config, field, enum: nil, default: nil, mask: false)
        cmd, args, opts = :ask, [question], {}
        if enum
          cmd = :select
          args << enum
          # Change default to its index in the enum
          default = index_of(enum, default)
          # Force the question if the supplied value is not valid
          config[field] = nil unless enum.include? config[field]
        end
        cmd = :mask if mask
        opts[:default] = default if default
        config[field] = prompt.send cmd, *args, opts if config[field].nil?
      end

      def tree_select(path, question: nil, file: false, page_size: 22, filter: true, cycle: false)
        path = Pathname.new(path) unless path.is_a? Pathname
        path = path.realpath

        dirs = path.children.select {|x| x.directory?}.sort
        files = file ? path.children.select {|x| x.file?}.sort : []

        choices = []
        choices << {name: "#{path}", value: path, disabled: file ? '' : false}
        choices << {name: '[..]', value: path.parent}

        dirs.each {|d| choices << {name: "[#{d.basename}]", value: d}}
        files.each {|f| choices << {name: f.basename.to_path, value: f}}

        question ||= "Select #{'file or ' if files}directory"
        selection = prompt.select question, choices,
                                  per_page: page_size, filter: filter, cycle: cycle, default: file ? 2 : 1

        return selection.to_path if selection == path || selection.file?

        tree_select selection, file: file, page_size: page_size, filter: filter, cycle: cycle
      end

    end

  end
end
