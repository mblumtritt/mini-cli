require_relative '../helper'

class RunTest < Test
  def setup
    super
    @pwd = Dir.pwd + "\n"
  end

  def test_std_out_only
    out = subject.run('pwd')
    assert_equal(@pwd, out)

    out = subject.run('pwd', stdout: true)
    assert_equal(@pwd, out)
  end

  def test_status
    result = subject.run('pwd', stdout: false)
    assert_instance_of(TrueClass, result)

    status = subject.run('pwd', status: true)
    assert_instance_of(Process::Status, status)

    out, status = subject.run('pwd', stdout: true, status: true)
    assert_equal(@pwd, out)
    assert_instance_of(Process::Status, status)
    assert(status.success?)
  end

  def test_std_error
    err = subject.run('ls /no-valid-dir', stderr: true)
    assert_match(/No such file or directory/, err)

    out, err = subject.run('ls /no-valid-dir', stdout: true, stderr: true)
    assert_empty(out)
    assert_match(/No such file or directory/, err)

    err, status = subject.run('ls /no-valid-dir', stderr: true, status: true)
    assert_match(/No such file or directory/, err)
    assert_instance_of(Process::Status, status)
    refute(status.success?)
  end

  def test_failure
    result = subject.run('this-is-not-a-valid-command')
    assert_instance_of(NilClass, result)
  end
end
