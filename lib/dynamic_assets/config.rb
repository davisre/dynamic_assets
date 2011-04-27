require 'yaml'

module DynamicAssets
  module Config

    CONFIG_VARS = %w(combine_asset_groups minify cache)

    def init(yml_path)
      @yml_path = yml_path
      assets_hash.present?
    end


    #  Configuration Queries

    def combine_asset_groups?
      @combine_asset_groups.nil? ? true : @combine_asset_groups
    end

    def minify?
      @minify.nil? ? true : @minify
    end

    def cache?
      @cache.nil? ? true : @cache
    end


    #  Asset Queries

    def asset_references_for_group_key(type, group_key)
      assets_hash[type].if_present { |gs| gs[:by_group][group_key] }
    end

    def asset_reference_for_name(type, name)
      assets_hash[type].if_present { |gs| gs[:by_name][name] }
    end


  protected

    def yml
      return @yml if @yml

      if File.exists? @yml_path
        @yml = YAML.load_file @yml_path
        @yml.delete("config").if_present { |c| configure c }
      else
        @yml = {}
      end

      @yml
    end

    def configure(values)
      values.each do |env_string, config_values|
        next unless env_string.split(/ *, */).include? Rails.env

        config_values.each do |name, value|
          raise "unknown config variable: #{name}" unless CONFIG_VARS.include? name
          instance_variable_set "@#{name}", value
        end
      end
    end

    def assets_hash
      return @assets if @assets

      assets = {}
      yml.each do |key, values|
        next if key == "config" || key.blank?

        type = key.to_sym
        groups = values

        typed_assets = assets[type] = {
          :by_name => {},
          :by_group => {}
        }

        groups.map do |group_hash|
          group_key = group_hash.keys.first
          group_names = group_hash.values.first

          assets_in_group = if combine_asset_groups?
            # Create a single AssetReference for the group
            name = group_key
            a = typed_assets[:by_name][name] ||=
              Reference.new_for_type(type, :name => name, :member_names => group_names)
            [a]
          else
            # Create an AssetReference for each member of the group
            group_names.map do |name|
              typed_assets[:by_name][name] ||= Reference.new_for_type type, :name => name
            end
          end

          typed_assets[:by_group][group_key.to_sym] = assets_in_group
        end
      end

      @assets = assets
    end
  end
end
