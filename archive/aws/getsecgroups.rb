#!/usr/bin/env ruby

require 'open3'

def aws_sec_groups()
  stdout, stderr, status = Open3.capture3("which aws")
  puts "#{stdout}"
  puts "#{status}"
end

aws_sec_groups
