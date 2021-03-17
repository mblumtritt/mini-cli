# frozen_string_literal: true

require 'open3'
require 'shellwords'
require_relative '../helper'

class ExecTest < Minitest::Test
  parallelize_me!

  def test_noop
    assert_empty(assert_no_err('noop'))
  end

  def test_noop_help
    assert_equal("Usage: noop\n", assert_no_err('noop', '--help'))
  end

  def test_sequence
    expected = [
      'before_1[]',
      'before_2[]',
      "parse_argv[{\"FILES\"=>[]}]",
      "main[{\"FILES\"=>[]}]",
      'after_2[]',
      'after_1[]'
    ]
    assert_equal(expected, assert_no_err('sequence').split("\n"))
  end

  def test_sequence_help
    expected = [
      'before_1[]',
      'before_2[]',
      'Usage: sequence [OPTIONS]',
      '',
      'Options:',
      '-x, --exit  early exit',
      '-e, --error exit with error',
      'after_2[]',
      'after_1[]'
    ]
    assert_equal(expected, assert_no_err('sequence', '--help').split("\n"))
  end

  def test_sequence_early_exit
    expected = [
      'before_1[]',
      'before_2[]',
      "parse_argv[{\"exit\"=>true, \"FILES\"=>[]}]",
      "main[{\"exit\"=>true, \"FILES\"=>[]}]",
      'after_2[]',
      'after_1[]'
    ]
    assert_equal(expected, assert_no_err('sequence', '-x').split("\n"))
  end

  def test_sequence_error
    expected = [
      'before_1[]',
      'before_2[]',
      "parse_argv[{\"error\"=>true, \"FILES\"=>[]}]",
      "main[{\"error\"=>true, \"FILES\"=>[]}]",
      'after_2[]',
      'after_1[]'
    ]
    std, err, status = invoke('sequence', '-e')
    assert_same(42, status.exitstatus)
    assert_equal("sequence: !error!\n", err)
    assert_equal(expected, std.split("\n"))
  end

  def assert_no_err(...)
    std, err = assert_success(...)
    assert_empty(err)
    std
  end

  def assert_success(...)
    std, err, status = invoke(...)
    assert(status.success?)
    return std, err
  end

  def invoke(name, *args)
    Open3.capture3(
      Shellwords.join(
        [
          RbConfig.ruby,
          '--disable',
          'gems',
          '--disable',
          'did_you_mean',
          '--disable',
          'rubyopt',
          File.expand_path("../apps/#{name}", __dir__)
        ] + args
      )
    )
  end
end
