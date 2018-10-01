require 'libis/tools/spreadsheet'
require 'awesome_print'

module Libis
  module Metadata
    module Cli
      module Downloader

        # noinspection RubyStringKeysInHashInspection
        VALID_SOURCES = {
            'alma' => 'alma.mms_id',
            'scope' => 'ID'
        }

        REQ_HEADERS = {term: 'Term'}
        OPT_HEADERS = {pid: 'Pid', filename: 'File'}

        def self.included(klass)
          klass.class_exec do
            desc 'download [options] [TERM[:PID] ...]', 'Download metadata from Alma or Scope'
            long_desc <<-DESC
      
            'download [TERM ...]' will download metadata from Alma or Scope and convert it to Dublin Core.
          
            The output format can either be Dublin Core or a Rosetta MD Update file. If you supply a Rosetta IE PID the 
            tool will generate a Rosetta MD Update file, a Dublin Core XML file if you don't. Note that there is no 
            check if the IE PID is a valid one.
          
            Any TERM argument that starts with a '@' will be interpreted as an input file name. The input file name can
            be:

            * a simple text file. File extension should be '.txt' and each non-empty line is interpreted as if it was
              supplied as a TERM argument on the command line.

            * a comma-delimited file (CSV). File extension should be '.csv'.

            * a tab-deliimited file (TSV). File extension should be '.tsv'.

            * a spreadsheet. Excel files (.xls or xlsx) and OpenOffice/LibreOffice Calc files (.ods) are supported.
              '@<sheet_name>' must be appended to the file name to select the proper sheet tab.

            For the CSV, TSV and spreadsheets: if there is no header row, the first column should contain the search 
            terms. If present, the second column should contain PID info and the third column FILE info. Other columns 
            are ignored. If there is a header row, it should contain at least a cell with the text 'Term'. That column 
            is expexted to contain the search terms. If a column header with the text 'Pid' is found, the column data 
            will be expected to contain pids for the IE's to modify. If a column header with the text 'File' is found, 
            the column data will be expected to contain file names to save to.

            In any case, if the output file info is missing, the name defaults to the PID (if present) or the search 
            term. If the FILE info does not have a file extension, '.xml' will be added. 
            
            The list of TERM arguments will be processed automatically. If there are no terms supplied on the command 
            line, the program will ask for them until you supply an empty value. A TERM argument can contain PID and 
            FILE info separated by a ':' or whatever you supply for the separator option. TERM arguments supplied via 
            a simple text file are interpreted the same way.

            Examples:
            * abc => searches for 'abc' and save DC metadata in abc.xml
            * abc:123 => searches for 'abc' and generates MD Update in 123.xml
            * abc:123:xyz.data => searches for 'abc' and generates MD Update in xyz.data
            * abc::xyz => searches for 'abc' and save DC metadata in xyz.xml

            For any option that is not supplied on the command line and doesn't have a default value, the tool will 
            always ask you to supply a value, even if the '-q' option is given.

            DESC

            method_option :quiet, aliases: '-q', desc: 'Do not ask for options that have a default value',
                          type: :boolean, default: false
            method_option :metadata, aliases: '-m', banner: 'source', desc: 'Metadata source system',
                          default: VALID_SOURCES.keys.first, enum: VALID_SOURCES.keys
            method_option :field, aliases: '-f', banner: 'field_name', desc: 'Search field in the Metadata system;' +
                " default value depends on selected metadata source system: #{VALID_SOURCES}"
            method_option :library, aliases: '-l', banner: 'library_code', desc: 'Library code for Alma',
                          default: '32KUL_KUL'
            method_option :database, aliases: '-d', desc: 'Scope database to connect to'
            method_option :user, aliases: '-u', desc: 'Database user name'
            method_option :password, aliases: '-p', desc: 'Database password'
            method_option :target_dir, aliases: '-t', desc: 'Directory where files will be created', default: '.'
            method_option :separator, aliases: '-s', desc: 'Separator for the TERM arguments', default: ':'

          end
        end

        def download(*terms)

          unless Dir.exist?(options.target_dir)
            prompt.error "ERROR: target directory '#{options.target_dir}' does not exist"
            exit -1
          end

          md = Libis::Metadata::Downloader.new

          config = download_configure

          md.configure config

          if terms.empty?
            while (term = prompt.ask "Search #{config[:metadata]} for #{config[:field]}:")
              pid = prompt.ask 'IE PID to update:'
              filename = prompt.ask('File name:', default: "#{pid || term}.xml")
              download_one(service: md, term: term, pid: pid, filename: filename)
            end
          else
            terms.each do |term|
              if term =~ /^@((.+)@(.+)|(.+))$/
                sheet = $3
                file = $2 || $4
                unless File.exist? file
                  prompt.warn "WARNING: File name '#{file}' not found."
                  next
                end
                if File.extname(file) == '.txt'
                  File.open(file, 'r').each_line do |line|
                    line.strip!
                    next if line.empty?
                    x = split_term(line)
                    download_one(service: md, term: x[:term], pid: x[:pid], filename: x[:filename])
                  end
                else
                  opts = {required: REQ_HEADERS, optional: OPT_HEADERS, noheaders: REQ_HEADERS.merge(OPT_HEADERS)}
                  opts.merge!(col_sep: "\t", extension: :csv) if File.extname(file) == '.tsv'
                  Libis::Tools::Spreadsheet.foreach("#{file}#{sheet ? '|' + sheet : ''}", opts) do |row|
                    next if row[:term].nil? || row[:term] == 'Term'
                    download_one(service: md, term: row[:term], pid: row[:pid], filename: row[:filename])
                  end
                end
                next
              end
              x = split_term(term)
              download_one(service: md, term: x[:term], pid: x[:pid], filename: x[:filename])
            end
          end
        end

        protected

        def split_term(term)
          result = {}
          t, p, f = term.split(options.separator)
          result[:term] = t
          result[:pid] = p if p && !p.empty?
          result[:filename] = f if f && !f.empty?
          result
        end

        def download_one(service:, term:, pid: nil, filename: nil)
          filename += '.xml' unless (filename.nil? || !File.extname(filename).empty?)
          filename ||= "#{pid || term}.xml"
          service.download(term, filename, pid)
          prompt.ok "OK: #{filename}#{" [#{term}]"}"
        rescue Exception => e
          prompt.error e.message.strip
        end

        def download_configure
          result = options.quiet? ? options.key_strings_to_symbols : {}

          ask 'Metadata source:', result, :metadata, default: options.metadata, enum: VALID_SOURCES.keys
          # Set appropriate default for field depending on source selection
          result[:field] ||= VALID_SOURCES[result[:metadata]] if options.quiet?
          ask 'Search field:', result, :field, default: options.field || VALID_SOURCES[result[:metadata]]
          case result[:metadata]
          when 'alma'
            ask 'Library code:', result, :library, default: options.library
          when 'scope'
            ask 'Database name:', result, :database, default: options.database
            ask 'User name:', result, :user, default: options.user
            ask 'Password:', result, :password, default: options.password, mask: true
          else
            # Other source
          end
          result[:target_dir] = tree_select(options.target_dir, question: 'Target directory:') unless result[:target_dir]

          result
        end

      end
    end
  end
end