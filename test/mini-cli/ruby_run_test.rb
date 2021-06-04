# frozen_string_literal: true

require_relative '../helper'

class RubyRunTest < Test
  def test_simple
    result = subject.run_script('puts("Hello World")')
    assert_equal("Hello World\n", result)
  end

  def test_error
    result = subject.run_script('UNDEFINED')
    assert_match(/NameError/, result)
  end

  def test_chdir
    home = Dir.home
    refute(home == Dir.pwd)
    result = subject.run_script('print Dir.pwd', chdir: home)
    assert_equal(home, result)
  end

  def test_status
    status, result = subject.run_script('print :Ok', status: true)
    assert_instance_of(Process::Status, status)
    assert(status.success?)
    assert_equal('Ok', result)
  end

  def test_status_error
    status, result = subject.run_script('print :Err;exit 42', status: true)
    assert_instance_of(Process::Status, status)
    refute(status.success?)
    assert_same(42, status.exitstatus)
    assert_equal('Err', result)
  end

  def test_stream
    stream = StringIO.new('puts "Hello World"')
    result = subject.run_script(stream)
    assert_equal("Hello World\n", result)
  end
end
