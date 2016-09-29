#!/usr/bin/env ruby
require 'json'
require 'colorize'

def msg(message)
  print (message.ljust(45, '.') + ' ').uncolorize
end

def ok
  puts 'OK'.green
end

def error(message, data)
  raise "#{message}: #{data.inspect}" unless data.empty?
end

def validate
  schema.map do |group, items|
    items.select do |field, item|
      yield(item, group)
    end.map { |item| "#{group}.#{item.first}" }
  end.flatten
end

def schema
  @schema ||= JSON.parse(File.read(File.expand_path('../schema.json', __FILE__)))
end

begin
  msg 'Validate JSON syntax'
  schema
  ok

  msg 'Check types'
  wrong_types = validate do |item|
    !%w(boolean float integer string text json).include?(item['type'])
  end
  error('Invalid types found', wrong_types)
  ok

  msg 'Check that default is included in values'
  wrong_defaults = validate do |item|
    item['values'] && !item['values'].include?(item['default'])
  end
  error('Invalid defaults found', wrong_defaults)
  ok

  msg 'Default corresponds to type'
  wrong_defaults = validate do |item|
    valid = true
    valid = [true, false].include?(item['default']) if item['type'] == 'boolean'
    valid = item['default'].is_a?(Float) if item['type'] == 'float'
    valid = item['default'].is_a?(Integer) if item['type'] == 'integer'
    valid = item['default'].is_a?(String) if item['type'] == 'string' || item['type'] == 'text' || item['type'] == 'json'
    item['default'] && !valid
  end
  error('Invalid defaults found', wrong_defaults)
  ok

  msg 'Descriptions ends with dots'
  wrong_descriptions = validate do |item|
    !item['description'].end_with?('.')
  end
  error('Invalid descriptions found', wrong_descriptions)
  ok

  msg 'Booleans have defaults'
  wrong_booleans = validate do |item|
    item['type'] == 'boolean' && !(item['default'] == true || item['default'] == false)
  end
  error('Invalid booleans found', wrong_booleans)
  ok

  msg 'Proper dependencies'
  wrong_deps = validate do |item, group|
    item['depends'] && schema[group]['adapter'] && !(item['depends'] - schema[group]['adapter']['values']).empty?
  end
  error('Unknown dependency is set', wrong_deps)
  ok


rescue => e
  puts 'FAILED'.red
  puts e.message.red
  puts e.backtrace.join("\n").yellow
end
