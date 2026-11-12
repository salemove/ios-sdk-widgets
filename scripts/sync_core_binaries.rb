#!/usr/bin/env ruby
# frozen_string_literal: true

# Copies the binary target pins of an ios-bundle release into Widgets' manifests.
#
# A GliaCoreSDK release is built against exact versions of the binaries it links
# (GliaOpenTelemetry, PhoenixChannelsClient, TwilioVoice, WebRTC,
# GliaCoreDependency), and the Package.swift of the matching ios-bundle tag is
# where those versions are recorded. Bumping GliaCoreSDK alone leaves Widgets
# linking the binaries of the previous release.
#
# Targets a manifest does not share with ios-bundle are left alone, as are
# template placeholders such as ${CORE_SDK_SEMVER}.
#
# Usage: sync_core_binaries.rb <core version> <manifest>...

require 'net/http'
require 'uri'

BINARY_TARGET = /
  \.binaryTarget\(\s*
  name:\s*"(?<name>[^"]+)",\s*
  url:\s*"(?<url>[^"]+)",\s*
  checksum:\s*"(?<checksum>[^"]+)"\s*
  \)
/mx.freeze

def binary_targets(manifest)
  manifest.to_enum(:scan, BINARY_TARGET).map { Regexp.last_match }
end

version, *manifest_paths = ARGV
abort("Usage: #{File.basename($PROGRAM_NAME)} <core version> <manifest>...") if version.nil? || manifest_paths.empty?

uri = URI("https://raw.githubusercontent.com/salemove/ios-bundle/#{version}/Package.swift")
response = Net::HTTP.get_response(uri)
abort("Could not read #{uri}: HTTP #{response.code}") unless response.is_a?(Net::HTTPSuccess)

released = binary_targets(response.body).to_h { |target| [target[:name], target] }
abort("#{uri} declares no GliaCoreSDK binary target") unless released.key?('GliaCoreSDK')

manifest_paths.each do |path|
  manifest = File.read(path)

  synced = manifest.gsub(BINARY_TARGET) do |declaration|
    current = Regexp.last_match
    pin = released[current[:name]]
    next declaration if pin.nil? || current[:url].include?('${')

    declaration.sub(current[:url], pin[:url]).sub(current[:checksum], pin[:checksum])
  end

  File.write(path, synced)
  puts "#{path}: #{synced == manifest ? 'already in sync' : 'updated'} with ios-bundle #{version}"
end
