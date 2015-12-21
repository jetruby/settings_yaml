require 'hashie/mash'
require 'active_support/core_ext/hash'
require 'settings_yaml/version'

# Reads settings from `config/settings.yml` and `config/settings.local.yml` files. Local file
# overrides settings from main file.
#
# Settings are read from `application` section of YAML files and from a section named after current Rails
# environment. Settings for current envinronment have bigger priority than settings from the
# `application` section.
#
# @example `config/settings.yml`
#   application:
#     cloud:
#       enabled: false
#
#   production:
#     cloud:
#       enabled: true
#
# @example `config/initializers/00_settings.rb`
#   require 'settings_yaml'
#
#   Settings = SettingsYaml.load!
#
# @example Accessing settings
#   if Settings.cloud.enabled
#     ...
#   end
class SettingsYaml

  APPLICATION_SETTINGS_ROOT_NAME = 'application'

  class << self
    # @param filename [String]
    # @param environment [String]
    # @return [Hasie::Mash]
    def load!(filename='settings', environment=nil)
      main_settings, local_settings  = FileParser.parse("#{filename}.yml"), FileParser.parse("#{filename}.local.yml")

      result = Hashie::Mash.new
      result.deep_merge!( application_settings(main_settings) )
            .deep_merge!( environment_settings(main_settings, environment) )
            .deep_merge!( application_settings(local_settings) )
            .deep_merge!( environment_settings(local_settings, environment) )

      result
    end

    private

    # @param loaded_settings [Hash]
    # @param environment [String]
    # @return [Hash]
    def environment_settings(loaded_settings, environment)
      loaded_settings[(environment || default_env)] || {}
    end

    # @param loaded_settings [Hash]
    # @return [Hash]
    def application_settings(loaded_settings)
      loaded_settings[APPLICATION_SETTINGS_ROOT_NAME] || {}
    end

    # @return [String]
    def default_env
      defined? Rails ? Rails.env : nil
    end

    class FileParser
      class << self
        # @param filename [String]
        # @return [Hash]
        def parse(filename)
          file_contents   = File.read(file_path_by_name(filename))
          parsed_file     = ERB.new(file_contents).result

          YAML.load(parsed_file) || {}
        rescue Errno::ENOENT # File not found error
          {}
        end

        private

        # @param filename [String]
        # @return [FilePath]
        def file_path_by_name(filename)
          defined? Rails ? Rails.root.join('config', filename) : filename
        end
      end
    end
  end
end
