# frozen_string_literal: true

require 'open3'

module MiniCli
  def run(*cmd)
    opts = Hash === cmd.last ? __run_opt(cmd.last) : %i[stdout]
    opts.delete(:stderr) ? __run3(opts, cmd) : __run2(opts, cmd)
  rescue SystemCallError
    nil
  end

  private

  def __run3(opts, cmd)
    result = Open3.capture3(*cmd)
    result.shift unless opts.first == :stdout
    result.pop unless opts.last == :status
    result.size == 1 ? result.first : result
  end

  def __run2(opts, cmd)
    result = Open3.capture2e(*cmd)
    return result.last.success? if opts.empty?
    return result if opts.size == 2
    opts.first == :status ? result.last : result.first
  end

  def __run_opt(opts)
    %i[stdout stderr status].keep_if { |s| opts.delete(s) }
  end
end
