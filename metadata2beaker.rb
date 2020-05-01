#!/usr/bin/env ruby
require 'json'

def metadata2beaker(module_path, pidfile: false, use_fqdn: true)
  metadata = JSON.parse(File.read(File.join(module_path, 'metadata.json')))

  operatingsystems = Hash[metadata['operatingsystem_support'].map { |os| [os['operatingsystem'], os['operatingsystemrelease']] }]

  operatingsystems.sort.each do |os, releases|
    next unless ['CentOS', 'Fedora', 'Debian', 'Ubuntu'].include?(os)
    releases.each do |release|
      name = "#{os.downcase}#{release.tr('.', '')}-64"

      options = {}
      options[:hostname] = "#{name}.example.com" if use_fqdn
      # Docker messes up cgroups and modern systemd can't deal with that when
      # PIDFile is used.
      if pidfile
        case os
        when 'CentOS'
          options[:image] = 'centos:7.6.1810' if release == '7'
        when 'Ubuntu'
          options[:image] = 'ubuntu:xenial-20191212' if release == '16.04'
        end
      end

      setfile = name
      setfile += "{#{options.map { |key, value| "#{key}=#{value}" }.join(',')}}" if options
      yield setfile
    end
  end
end

if __FILE__ == $0
  ARGV.each do |module_path|
    puts "Setfiles for #{module_path}"
    metadata2beaker(module_path) do |setfile|
      puts "  #{setfile}"
    end
  end
end
