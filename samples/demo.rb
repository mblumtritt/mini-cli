# frozen_string_literal: true

require_relative '../lib/mini-cli'

include MiniCli

help <<~HELP, %w[TARGET [SOURCE]]
  -n, --name NAME  option requires NAME argument, has shortcut
      --url URL    option requires URL argument
  -s, --switch     option without any argument, has shortcut
      --opt        option without any argument
HELP

main do |args|
  puts("TARGET: #{args['TARGET']}")
  puts("SOURCE: #{args['SOURCE']}") if args.key?('SOURCE')
  puts("NAME: #{args['NAME']}") if args.key?('NAME')
  puts("URL: #{args['URL']}") if args.key?('URL')
  puts("FILES: #{args['FILES']}") unless args['FILES'].empty?
  puts('--switch was given') if args.key?('switch')
  puts('--opt was given') if args.key?('opt')
end
