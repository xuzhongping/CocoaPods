require 'molinillo/dependency_graph'

module Pod
  class Installer
    class Analyzer
      # Generates dependencies that require the specific version of the Pods
      # that haven't changed in the {Lockfile}.
      module LockingDependencyAnalyzer
        # Generates dependencies that require the specific version of the Pods
        # that haven't changed in the {Lockfile}.
        #
        # These dependencies are passed to the {Resolver}, unless the installer
        # is in update mode, to prevent it from upgrading the Pods that weren't
        # changed in the {Podfile}.
        #
        # @param [Lockfile] lockfile the lockfile containing dependency constraints
        #
        # @param [Array<String>] pods_to_update
        #        List of pod names which needs to be updated because installer is
        #        in update mode for these pods. Pods in this list and all their recursive dependencies
        #        will not be included in generated dependency graph
        #
        # @param [Array<String>] pods_to_unlock
        #        List of pod names whose version constraints will be removed from  the generated dependency graph.
        #        Recursive dependencies of the pods won't be affected. This is currently used to force local pods
        #        to be evaluated again whenever checksum of the specification of the local pods changes.
        #
        # @return [Molinillo::DependencyGraph<Dependency>] the dependencies
        #         generated by the lockfile that prevent the resolver to update
        #         a Pod.
        #
        def self.generate_version_locking_dependencies(lockfile, pods_to_update, pods_to_unlock = [])
          dependency_graph = Molinillo::DependencyGraph.new

          if lockfile
            added_dependency_strings = Set.new

            explicit_dependencies = lockfile.dependencies
            explicit_dependencies.each do |dependency|
              # 将依赖作为顶点添加到依赖图中
              dependency_graph.add_vertex(dependency.name, dependency, true)
            end

            # 根据依赖关系生成图中顶点的边
            pods = lockfile.to_hash['PODS'] || []
            pods.each do |pod|
              add_to_dependency_graph(pod, [], dependency_graph, pods_to_unlock, added_dependency_strings)
            end

            pods_to_update = pods_to_update.flat_map do |u|
              root_name = Specification.root_name(u).downcase
              dependency_graph.vertices.each_key.select { |n| Specification.root_name(n).downcase == root_name }
            end

            pods_to_update.each do |u|
              dependency_graph.detach_vertex_named(u)
            end

            # 从lock文件获取source并赋值给depend
            dependency_graph.each do |vertex|
              next unless dep = vertex.payload
              dep.podspec_repo ||= lockfile.spec_repo(dep.root_name)
            end
          end

          dependency_graph
        end

        # Generates a completely 'unlocked' dependency graph.
        #
        # @return [Molinillo::DependencyGraph<Dependency>] an empty dependency
        #         graph
        #
        def self.unlocked_dependency_graph
          Molinillo::DependencyGraph.new
        end

        private

        def self.add_child_vertex_to_graph(dependency_string, parents, dependency_graph, pods_to_unlock, added_dependency_strings)
          return unless added_dependency_strings.add?(dependency_string)
          dependency = Dependency.from_string(dependency_string)
          if pods_to_unlock.include?(dependency.root_name)
            dependency = Dependency.new(dependency.name)
          end
          vertex = dependency_graph.add_child_vertex(dependency.name, nil, parents, nil)
          dependency = vertex.payload.merge(dependency) if vertex.payload
          vertex.payload = dependency
          dependency
        end

        def self.add_to_dependency_graph(object, parents, dependency_graph, pods_to_unlock, added_dependency_strings)
          case object
          when String
            add_child_vertex_to_graph(object, parents, dependency_graph, pods_to_unlock, added_dependency_strings)
          when Hash
            object.each do |key, value|
              dependency = add_child_vertex_to_graph(key, parents, dependency_graph, pods_to_unlock, added_dependency_strings)
              value.each { |v| add_to_dependency_graph(v, [dependency.name], dependency_graph, pods_to_unlock, added_dependency_strings) }
            end
          end
        end
      end
    end
  end
end
