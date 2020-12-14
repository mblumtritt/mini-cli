# frozen_string_literal: true

module MiniCli
  def self.included(mod)
    source = caller_locations(1, 1).first.absolute_path
    mod.const_set(:MiniCli__, Instance.new(source))
  end

  def name(name = nil)
    __minicli__.name(name)
  end

  def help(helptext, *args)
    __minicli__.help(helptext, args)
  end

  def show_help
    __minicli__.show_help
  end

  def show_errors?
    __minicli__.show_errors
  end

  def show_errors=(value)
    __minicli__.show_errors = value ? true : false
  end

  def error(code, message = nil)
    $stderr.puts("#{name}: #{message}") if message && show_errors?
    exit(code)
  end

  def parse_argv(argv = nil, &argv_converter)
    return __minicli__.converter = argv_converter if argv_converter
    argv ||= Array.new(ARGV)
    exit(show_help) if argv.index('--help') || argv.index('-h')
    __minicli__.convert(__minicli__.parse(argv, method(:error).to_proc))
  end

  def main(args = nil)
    at_exit do
      yield(args || parse_argv)
    rescue Interrupt
      error(130, 'aborted')
    end
  end

  private

  def __minicli__
    self.class::MiniCli__
  end

  class Instance
    attr_reader :source
    attr_writer :converter
    attr_accessor :show_errors

    def initialize(source)
      @source = source
      @name = File.basename(source, '.*')
      @parser = @converter = nil
      @show_errors = true
    end

    def name(name = nil)
      name ? @name = name.to_s : @name
    end

    def help(helptext, args)
      @parser = ArgvParser.new(helptext, args)
    end

    def show_help
      parser.show_help(@name)
      true
    end

    def parse(argv, error)
      parser.parse(argv, error)
    end

    def convert(args)
      @converter ? @converter.call(args) || args : args
    end

    private

    def parser
      @parser ||= ArgvParser.new(nil, [])
    end

    class ArgvParser
      def initialize(helptext, args)
        @helptext = helptext.to_s
        @args = args.flatten.map!(&:to_s).uniq
        @options = nil
      end

      def show_help(name)
        parse_help! unless @options
        print("Usage: #{name}")
        print(' [OPTIONS]') unless @options.empty?
        print(' ', @args.join(' ')) unless @args.empty?
        puts
        puts(nil, 'Options:') unless @options.empty?
        puts(@helptext) unless @helptext.empty?
      end

      def parse(argv, error)
        @error, @result = error, {}
        parse_help! unless @options
        process(parse_argv(argv))
      end

      private

      def parse_argv(argv)
        arguments = []
        while (arg = argv.shift)
          case arg
          when '--'
            break arguments += argv
          when /\A--([[[:alnum:]]-]+)\z/
            handle_option(Regexp.last_match[1], argv)
          when /\A-([[:alnum:]]+)\z/
            parse_options(Regexp.last_match[1], argv)
          else
            arguments << arg
          end
        end
        arguments
      end

      def error(msg)
        @error[1, msg]
      end

      def process(arguments)
        @args.each do |arg|
          process_arg(arg, arguments.shift) unless arg.index('..')
        end
        arguments.unshift(@result['FILES']) if @result.key?('FILES')
        @result['FILES'] = arguments
        @result
      end

      def process_arg(arg, value)
        if arg.start_with?('[')
          @result[arg[1..-2]] = value if value
        else
          @result[arg] = value || error("parameter expected - #{arg}")
        end
      end

      def handle_option(option, argv, test = ->(k) { option == k })
        key = @options[option] || error("unknown option - #{option}")
        @result[key] = test[key] and return
        @result[key] = value = argv.shift
        return unless value.nil? || value.start_with?('-')
        error("parameter #{key} expected - --#{option}")
      end

      def parse_options(options, argv)
        test = ->(k) { k == k.downcase }
        options.each_char { |opt| handle_option(opt, argv, test) }
      end

      def parse_help!
        @options = {}
        @helptext.each_line do |line|
          case line
          when /-([[:alnum:]]), --([[[:alnum:]]-]+) ([[:upper:]]+)\s+\S+/
            option_with_argument(Regexp.last_match)
          when /--([[[:alnum:]]-]+) ([[:upper:]]+)\s+\S+/
            short_option_with_argument(Regexp.last_match)
          when /-([[:alnum:]]), --([[[:alnum:]]-]+)\s+\S+/
            option(Regexp.last_match)
          when /--([[[:alnum:]]-]+)\s+\S+/
            short_option(Regexp.last_match)
          end
        end
      end

      def option_with_argument(match)
        @options[match[1]] = @options[match[2]] = match[3]
      end

      def short_option_with_argument(match)
        @options[match[1]] = match[2]
      end

      def option(match)
        @options[match[1]] = @options[match[2]] = match[2]
      end

      def short_option(match)
        @options[match[1]] = match[1]
      end
    end
  end

  private_constant(:Instance)
end
