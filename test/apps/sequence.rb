# frozen_string_literal: true
# demonstrates the call sequence

require_relative '../../lib/mini-cli'
include(MiniCli)

help <<~HELP
  -x, --exit  early exit
  -e, --error exit with error
HELP

main do |*args|
  puts('main' + args.inspect)
  exit if args.first['exit']
  error(42, '!error!') if args.first['error']
end

before { |*args| puts('before_1' + args.inspect) }
after { |*args| puts('after_1' + args.inspect) }
before { |*args| puts('before_2' + args.inspect) }
after { |*args| puts('after_2' + args.inspect) }

parse_argv do |*args|
  puts('parse_argv' + args.inspect)
  args.first
end
