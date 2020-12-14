# frozen_string_literal: true

require_relative '../lib/mini-cli'

include MiniCli

help <<~HELP, %w[TARGET [SOURCE]]
  -n, --name NAME  option requires NAME argument, has shortcut
      --url URL    option requires URL argument
  -s, --switch     option without any argument, has shortcut
      --opt        option without any argument
HELP

main { |cfg| cfg.each_pair { |key, value| puts("#{key}: #{value}") } }

parse_argv do |args|
  Struct
    .new(:target, :sources, :name, :url, :switch, :opt)
    .new
    .tap do |cfg|
      cfg.target = args['TARGET']
      cfg.sources = args['FILES'] # args['FILES'] is an array containing all surplus arguments
      source = args['SOURCE'] || ENV['SOURCE']
      cfg.sources.unshift(source) if source
      cfg.sources << 'STDIN' if cfg.sources.empty?
      cfg.name = args['NAME'] || 'default_name'
      cfg.url = args['URL'] || 'www.url.test'
      cfg.switch = args.key?('switch')
      cfg.opt = args.key?('opt')
    end
end
