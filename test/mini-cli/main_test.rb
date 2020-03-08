require_relative '../helper'

class MainTest < Test
  def test_defaults
    assert_equal('helper', subject.name)
    assert_output("Usage: helper\n"){ subject.show_help }
  end

  def test_methods
    subject = Class.new{ include MiniCli }.new

    expected_methods = %i[
      error
      help
      main
      name
      parse_argv
      run
      show_help
    ].sort!
    methods = (subject.methods - Object.new.methods).sort!
    assert_equal(expected_methods, methods)
  end

  def test_error
    assert_stop_with_error(42, 'some error text') do
      subject.error(42, 'some error text')
    end

    assert_stop_with_error(21, 'error') do
      subject.error(21, :error)
    end
  end

  def test_help_simple
    subject.help 'Some helptext'
    expected_text = <<~EXPECTED
      Usage: helper
      Some helptext
    EXPECTED

    assert_output(expected_text){ subject.show_help }
  end

  def test_help_with_args
    subject.help <<~HELP, 'ARG1', :ARG2
      Some helptext comes
      here
    HELP

    expected_text = <<~EXPECTED
      Usage: helper ARG1 ARG2
      Some helptext comes
      here
    EXPECTED

    assert_output(expected_text){ subject.show_help }
  end

  def test_argument_required
    subject.help :text, :ARG

    assert_stop_with_error(1, 'parameter expected - ARG') do
      subject.parse_argv(as_argv(''))
    end

    expected = {'ARG' => 'arg', 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('arg')))

    expected = {'ARG' => 'arg1', 'FILES' => %w[arg2 arg3]}
    assert_equal(expected, subject.parse_argv(as_argv('arg1 arg2 arg3')))
  end

  def test_name
    subject.name 'test-42'
    assert_equal('test-42', subject.name)
  end

  def test_argument_optional
    subject.help :text, 'ARG1', '[ARG2]'

    assert_stop_with_error(1, 'parameter expected - ARG1') do
      subject.parse_argv(as_argv(''))
    end

    expected = {'ARG1' => 'arg1', 'ARG2' => 'arg2', 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('arg1 arg2')))

    expected = {'ARG1' => 'arg', 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('arg')))
  end

  def test_options
    subject.help <<~HELP
      -n, --named NAME     option NAME with shortcut
      --named-long LNAME   option LNAME without shortcut
      -u, --unnamed        option unnamed with shortcut
      --un-named           option un-named without shortcut

      Some additional explaination can be here
    HELP

    expected = {'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('')))

    expected = {'NAME' => 'name', 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('--named name')))
    assert_equal(expected, subject.parse_argv(as_argv('-n name')))

    expected = {'LNAME' => 'long', 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('--named-long long')))

    expected = {'unnamed' => true, 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('--unnamed')))
    assert_equal(expected, subject.parse_argv(as_argv('-u')))

    expected = {'un-named' => true, 'FILES' => []}
    assert_equal(expected, subject.parse_argv(as_argv('--un-named')))

    expected = {
      'NAME' => 'name',
      'LNAME' => 'long',
      'unnamed' => true,
      'un-named' => true,
      'FILES' => %w[FILE1 FILE2]
    }

    result = subject.parse_argv(%w[
      --named name
      --named-long long
      --unnamed
      --un-named
      FILE1
      FILE2
    ])
    assert_equal(expected, result)

    result = subject.parse_argv(%w[
      -nu name
      --named-long long
      --un-named
      FILE1
      FILE2
    ])
    assert_equal(expected, result)
  end

  def test_complex_options
    subject.help <<~HELP, %w[INFILE OUTFILE [OPTFILE]]
      -n, --named NAME   key 'NAME'
      -p, --port PORT    key 'PORT'
      -u, --un-named     key 'unnamed'
    HELP

    expected = {
      'INFILE' => 'in',
      'OUTFILE' => 'out',
      'NAME' => 'name',
      'PORT' => 'port',
      'un-named' => true,
      'FILES' => []
    }
    result = subject.parse_argv(as_argv('-nup name port in out'))
    assert_equal(expected, result)

    expected = {
      'INFILE' => 'in',
      'OUTFILE' => 'out',
      'OPTFILE' => 'opt',
      'NAME' => 'name',
      'PORT' => 'port',
      'un-named' => true,
      'FILES' => %w[file]
    }
    result = subject.parse_argv(as_argv('-nup name port in out opt file'))
    assert_equal(expected, result)
  end
end
