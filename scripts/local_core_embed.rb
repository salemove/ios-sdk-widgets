#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds or removes GliaCore in the Embed Frameworks phase of the app targets.
#
# With `scripts/local-core enable`, GliaCore is a dynamic framework built from
# sources, and an app embeds a dynamic package product only when its Embed
# Frameworks phase lists it. The released GliaCore is made of binary targets,
# which Xcode embeds on its own, so the committed project must not list it.
#
# The file is edited as text: the xcodeproj gem rewrites the whole project in
# its own order. The entries get fixed IDs derived from the target name, so
# `remove` finds exactly what `add` wrote, also after Xcode has saved the file.
#
# Usage: local_core_embed.rb add|remove|state <project.pbxproj | ->

require 'digest'

APP_TARGETS = %w[TestingApp GliaTestApp].freeze
PRODUCT = 'GliaCore'
COMMENT = "#{PRODUCT} in Embed Frameworks"
BUILD_FILES_BEGIN = "/* Begin PBXBuildFile section */\n"
BUILD_FILES_END = '/* End PBXBuildFile section */'
BUILD_FILE_LINE = /\A\t\t[0-9A-F]{24} /.freeze

def entry_id(target)
  Digest::MD5.hexdigest("scripts/local-core #{PRODUCT} #{target}")[0, 24].upcase
end

def target_block(project, target)
  project[%r{^\t\t[0-9A-F]{24} /\* #{Regexp.escape(target)} \*/ = \{\n\t\t\tisa = PBXNativeTarget;.*?^\t\t\};}m] or
    abort "local_core_embed: target #{target} not found"
end

def embed_phase_id(block, target)
  block[%r{^\t\t\t\t([0-9A-F]{24}) /\* Embed Frameworks \*/,$}, 1] or
    abort "local_core_embed: #{target} has no Embed Frameworks phase"
end

def product_dependency_id(block, target)
  dependencies = block[/packageProductDependencies = \((.*?)\);/m, 1].to_s
  dependencies[%r{([0-9A-F]{24}) /\* #{PRODUCT} \*/}, 1] or
    abort "local_core_embed: #{target} does not link #{PRODUCT}"
end

def add(project)
  APP_TARGETS.reduce(project) do |result, target|
    id = entry_id(target)
    next result if complete?(result, id)

    result = remove_lines(result, [id])
    block = target_block(result, target)
    product_id = product_dependency_id(block, target)
    phase_id = embed_phase_id(block, target)
    build_file = "\t\t#{id} /* #{COMMENT} */ = {isa = PBXBuildFile; productRef = #{product_id} /* #{PRODUCT} */; " \
                 "settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };\n"
    result = insert_build_file(result, build_file, id)
    insert_phase_file(result, phase_id, "\t\t\t\t#{id} /* #{COMMENT} */,\n", target)
  end
end

# Keeps the PBXBuildFile section sorted by ID, as Xcode writes it. A line in an
# unexpected format makes the order unknowable, so the entry then goes last.
def insert_build_file(project, line, id)
  section = project.index(BUILD_FILES_BEGIN) or abort 'local_core_embed: no PBXBuildFile section'
  section_end = project.index(BUILD_FILES_END, section) or abort 'local_core_embed: no end of PBXBuildFile section'
  position = section + BUILD_FILES_BEGIN.length
  while position < section_end
    next_line_end = project.index("\n", position) + 1
    unless project[position...next_line_end].match?(BUILD_FILE_LINE)
      position = section_end
      break
    end
    break if project[position + 2, 24] > id

    position = next_line_end
  end
  project.dup.insert(position, line)
end

def insert_phase_file(project, phase_id, line, target)
  phase = project.index(%r{^\t\t#{phase_id} /\* Embed Frameworks \*/ = \{}) or
    abort "local_core_embed: Embed Frameworks phase of #{target} not found"
  files_end = project.index("\t\t\t);\n", project.index("files = (\n", phase))
  project.dup.insert(files_end, line)
end

def remove(project)
  remove_lines(project, APP_TARGETS.map { |target| entry_id(target) })
end

def remove_lines(project, ids)
  project.lines.reject { |line| ids.any? { |id| line.include?(id) } }.join
end

# An entry is the build file line plus its reference in the Embed phase.
def complete?(project, id)
  project.scan(id).length == 2
end

# all: every app embeds GliaCore; none: no app does; partial: anything in between.
def state(project)
  return 'all' if APP_TARGETS.all? { |target| complete?(project, entry_id(target)) }
  return 'none' if APP_TARGETS.none? { |target| project.include?(entry_id(target)) }

  'partial'
end

command, path = ARGV
unless %w[add remove state].include?(command) && path
  abort 'Usage: local_core_embed.rb add|remove|state <project.pbxproj | ->'
end

project = path == '-' ? $stdin.read : File.read(path)
case command
when 'state' then puts state(project)
else
  abort 'local_core_embed: add and remove need a file, not -' if path == '-'
  updated = command == 'add' ? add(project) : remove(project)
  File.write(path, updated) unless updated == project
end
