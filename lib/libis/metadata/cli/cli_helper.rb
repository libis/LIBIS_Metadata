module Libis
  module Metadata
    module Cli
      module Helper

        module ClassMethods

          def exit_on_failure?
            true
          end

        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        attr_reader :prompt

        def initialize(*args)
          @prompt = TTY::Prompt.new
          super
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
end