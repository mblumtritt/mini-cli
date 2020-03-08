# frozen_string_literal: true

module MiniCli
  def self.included(_)
    return if const_defined?(:SRC)
    const_set(:SRC, caller_locations(1, 1).first.absolute_path)
  end

  def name(name = nil)
    return name ? @__name = name : @__name if defined?(@__name)
    @__name = name || File.basename(MiniCli::SRC, '.*')
  end

  def help(helptext, *args)
    @__argv_parser = ArgvParser.new(helptext, args)
  end

  def show_help
    __argv_parser.show_help(name)
    true
  end

  def error(code, message)
    $stderr.puts("#{name}: #{message}")
    exit(code)
  end

  def parse_argv(argv = nil, &block)
    return @__argv_converter = block if block
    argv ||= ARGV.dup
    exit(show_help) if argv.index('--help') || argv.index('-h')
    args = __argv_parser.parse(argv, method(:error).to_proc)
    defined?(@__argv_converter) ? @__argv_converter.call(args) || args : args
  end

  def main(args = nil)
    at_exit do
      yield(args || parse_argv)
    rescue Interrupt
      error(130, 'aborted')
    end
  end

  private

  def __argv_parser
    @__argv_parser ||= ArgvParser.new(nil, [])
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
      puts(nil, 'Valid Options:') unless @options.empty?
      puts(@helptext) unless @helptext.empty?
    end

    def parse(argv, error)
      @error = error
      parse_help! unless @options
      @result, arguments = {}, []
      loop do
        case arg = argv.shift
        when nil
          break
        when '--'
          arguments += argv
          break
        when /\A--([[[:alnum:]]-]+)\z/
          handle_option(Regexp.last_match[1], argv)
        when /\A-([[:alnum:]]+)\z/
          parse_options(Regexp.last_match[1], argv)
        else
          arguments << arg
        end
      end
      process(arguments)
    end

    private

    def error(msg)
      @error.call(1, msg)
    end

    def process(arguments)
      @args.each do |arg|
        next if arg.index('..')
        value = arguments.shift
        if arg.start_with?('[')
          @result[arg[1..-2]] = value if value
        else
          @result[arg] = value || error("parameter expected - #{arg}")
        end
      end
      arguments.unshift(@result['FILES']) if @result.key?('FILES')
      @result['FILES'] = arguments
      @result
    end

    def handle_option(option, argv)
      key = @options[option] || error("unknown option - #{option}")
      return @result[key] = true if option == key
      @result[key] = value = argv.shift
      return unless value.nil? || value.start_with?('-')
      error("parameter #{key} expected - --#{option}")
    end

    def parse_options(options, argv)
      options.each_char do |opt|
        key = @options[opt] || error("unknown option - #{opt}")
        next @result[key] = true if key == key.downcase
        @result[key] = value = argv.shift
        next unless value.nil? || value.start_with?('-')
        error("parameter #{key} expected - -#{opt}")
      end
    end

    def parse_help!
      @options = {}
      @helptext.each_line do |line|
        case line
        when /-([[:alnum:]]), --([[[:alnum:]]-]+) ([[:upper:]]+)\s+\S+/
          named_option(Regexp.last_match)
        when /--([[[:alnum:]]-]+) ([[:upper:]]+)\s+\S+/
          named_option_short(Regexp.last_match)
        when /-([[:alnum:]]), --([[[:alnum:]]-]+)\s+\S+/
          option(Regexp.last_match)
        when /--([[[:alnum:]]-]+)\s+\S+/
          option_short(Regexp.last_match)
        end
      end
    end

    def named_option(match)
      @options[match[1]] = @options[match[2]] = match[3]
    end

    def named_option_short(match)
      @options[match[1]] = match[2]
    end

    def option(match)
      @options[match[1]] = @options[match[2]] = match[2]
    end

    def option_short(match)
      @options[match[1]] = match[1]
    end
  end

  private_constant(:ArgvParser)
end
