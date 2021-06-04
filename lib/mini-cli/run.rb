# frozen_string_literal: true

module MiniCli
  def run(*cmd, stdin_data: nil, status: false, chdir: nil)
    in_read, in_write = IO.pipe
    opts = { err: %i[child out], in: in_read }
    opts[:chdir] = chdir if chdir
    ret = IO.popen(*cmd, opts, &__run_proc(stdin_data, in_write))
    status ? [Process.last_status, ret] : ret
  rescue Errno::ENOENT
    nil
  ensure
    in_read&.close
    in_write&.close
  end

  def run_ruby(*cmd, **run_options)
    require 'shellwords'
    run(Shellwords.join(RUBY_CMD + cmd), **run_options)
  end

  def run_script(script, status: false, chdir: nil)
    run_ruby(stdin_data: script, status: status, chdir: chdir)
  end

  private

  RUBY_CMD =
    %w[--disable gems --disable did_you_mean --disable rubyopt].unshift(
      RbConfig.ruby
    ).freeze

  def __run_proc(stdin_data, in_write)
    return :read unless stdin_data
    proc do |out|
      in_write.sync = true
      if stdin_data.respond_to?(:readpartial)
        IO.copy_stream(stdin_data, in_write)
      else
        in_write.write(stdin_data)
      end
      in_write.close
      out.read
    end
  end
end
