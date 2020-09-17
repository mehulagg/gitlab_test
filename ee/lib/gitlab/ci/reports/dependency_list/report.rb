# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module DependencyList
        class Report
          def initialize
            @dependencies = {}
            @dependencies_by_iid = {}
          end

          def dependencies
            @dependencies.values.map(&:to_hash)
          end

          def add_dependency(dependency)
            dep = Dependency.new(dependency)
            key = dep.composite_key
            if @dependencies.has_key?(key)
              existing_dependency = @dependencies[key]
              existing_dependency.update_dependency(dependency)
            else
              pm = dep.package_manager
              unless @dependencies_by_iid[pm]
                @dependencies_by_iid[pm] = {}
              end
              @dependencies_by_iid[pm][dep.iid] = { name: dep.name, version: dep.version }
              @dependencies[key] = dep
            end
          end

          def generate_dependency_path!
            @dependencies = @dependencies.each_value do |dep|
              return if dep.location[:top_level]

              pm = dep.package_manager
              dic = @dependencies_by_iid[pm]
              dep.location[:ancestors].map! do |a|
                dic[a[:iid]]
              end
            end
          end

          def apply_license(license)
            dependencies.each do |dependency|
              next unless license.dependencies.find { |license_dependency| license_dependency.name == dependency[:name] }
              next if dependency[:licenses].find { |license_hash| license_hash[:name] == license.name }

              dependency[:licenses].push(name: license.name, url: license.url)
            end
          end

          def dependencies_with_licenses
            dependencies.select { |dependency| dependency[:licenses].any? }
          end
        end
      end
    end
  end
end
