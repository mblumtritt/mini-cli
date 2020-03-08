# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/parallel'

require_relative '../lib/mini-cli'
require_relative '../lib/mini-cli/run'

class Test < Minitest::Test
  parallelize_me!
  attr_reader :subject

  def setup
    @subject = Class.new do
      include MiniCli
      attr_reader :exit_args

      def exit(*args)
        @exit_args = args
      end
    end.new
  end

  def assert_stop_with_error(code, text, &block)
    assert_output(nil, "helper: #{text}\n", &block)
    assert_equal([code], subject.exit_args)
  end

  def as_argv(str)
    str.split(' ')
  end
end
