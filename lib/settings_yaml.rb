require 'hashie/mash'
require 'active_support/core_ext/hash'
require 'settings_yaml/version'

# Reads settings from `config/settings.yml` and `config/settings.local.yml` files. Local file
# overrides settings from main file.
#
# Settings are read from `global` section of YAML files and from a section named after current Rails
# environment. Settings for current envinronment have bigger priority than settings from the
# `global` section.
#
# @example `config/settings.yml`
#   global:
#     cloud:
#       enabled: false
#
#   production:
#     cloud:
#       enabled: true
#
# @example `config/initializers/00_settings.rb`
#   require 'handsome_extensions/settings'
#
#   Settings = HandsomeExtensions::Settings.new.load!
#
# @example Accessing settings
#   if Settings.cloud.enabled
#     ...
#   end
class SettingsYaml < Hashie::Mash
  # @return [Hasie::Mash]
  def load!
    self.deep_merge! settings_from_file('settings.yml')
    self.deep_merge! settings_from_file('settings.local.yml')
    self
  end

  private

  # @param filename [String]
  # @return [Hash]
  def settings_from_file(filename)
    file_path       = Rails.root.join 'config', filename
    file_contents   = File.read(file_path)
    parsed_file     = ERB.new(file_contents).result
    loaded_settings = YAML.load(parsed_file)

    {}.tap do |settings|
      if loaded_settings
        settings.deep_merge! loaded_settings['global'] || {}
        settings.deep_merge! loaded_settings[Rails.env] || {}
      end
    end
  rescue Errno::ENOENT # File not found error
    {}
  end
end

