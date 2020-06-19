# frozen_string_literal: true

require_relative '../lib/mini-cli'

include MiniCli

help <<~HELP

  This is a very simple sample without any required parameter.
HELP

main { |args| puts("given files: #{args['FILES']}") }
