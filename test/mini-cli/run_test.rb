# frozen_string_literal: true

require_relative '../helper'

class RunTest < Test
  def test_simple
    result = subject.run('pwd')
    assert_equal("#{Dir.pwd}\n", result)
  end

  def test_simple_error
    result = subject.run('ls /no-valid-dir')
    assert_match(/No such file or directory/, result)
  end

  def test_chdir
    home = Dir.home
    refute(home == Dir.pwd)
    result = subject.run('pwd', chdir: home)
    assert_equal("#{home}\n", result)
  end

  def test_status
    status, result = subject.run('pwd', status: true)
    assert_instance_of(Process::Status, status)
    assert(status.success?)
    assert_equal("#{Dir.pwd}\n", result)
  end

  def test_status_error
    status, result = subject.run('ls /no-valid-dir', status: true)
    assert_instance_of(Process::Status, status)
    refute(status.success?)
    assert_match(/No such file or directory/, result)
  end

  def test_stdin
    string = 'Hello World'
    result = subject.run('cat', stdin_data: string)
    assert_equal(string, result)
  end

  def test_stdin_stream
    stream = StringIO.new('Hello World')
    result = subject.run('cat', stdin_data: stream)
    assert_equal(stream.string, result)
  end

  def test_failure
    result = subject.run('this-is-not-a-valid-command')
    assert_instance_of(NilClass, result)
  end
end
