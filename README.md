# Mini Cli

This gem is a minimalistic, easy to use CLI framework with a very small footprint. I provides an easy to use argument parsing, help displaying, minimalistic error handling and some tools like executing external programs and gather their output.

## Installation

To use Mini CLI just install the gem with

```shell
gem install mini-cli
```

or include it to you project's gemspec:

```ruby
gem 'mini-cli'
```

## Sample

A very minimalistic program may look like this sample program:

```ruby
require 'mini-cli'

include MiniCli

help <<~HELP, %w[TARGET [SOURCE]]
  -n, --name NAME  option requires NAME argument, has shortcut
      --url URL    option requires URL argument
  -s, --switch     option without any argument, has shortcut
      --opt        option without any argument

  This is a sample application only.
HELP

main do |args|
  puts "TARGET: #{args['TARGET']}"
  puts "SOURCE: #{args['SOURCE']}" if args.key?('SOURCE')
  puts "NAME: #{args['NAME']}" if args.key?('NAME')
  puts "URL: #{args['URL']}" if args.key?('URL')
  puts "FILES: #{args['FILES']}" unless args['FILES'].empty?
  puts '--switch was given' if args.key?('switch')
  puts '--opt was given' if args.key?('opt')
end
```

The sample uses the powerful `#help` method to generate an argument parser which handles the command line for you. You only need to handle the given `Hash` parameter (named `args` in the sample) in the body of your `#main` block.

Executing the sample with `--help` or `-h` will provide following help screen:

```
Usage: sample [OPTIONS] TARGET [SOURCE]

Valid Options:
-n, --name NAME  option requires NAME argument, has shortcut
    --url URL    option requires URL argument
-s, --switch     option without any argument, has shortcut
    --opt        option without any argument

This is a sample application only.
```

See the `./samples` directory for more sample programs…
