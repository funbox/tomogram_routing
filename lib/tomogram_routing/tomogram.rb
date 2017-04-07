require 'multi_json'

module TomogramRouting
  class Tomogram < Array
    def self.craft(docs)
      new(MultiJson.load(docs).inject([]) do |res, doc|
        res.push(Request.new.merge(doc))
      end)
    end

    def find_request(method:, path:)
      path = find_request_path(method: method, path: path)
      find do |doc|
        doc['path'] == path && doc['method'] == method
      end
    end

    private

    def initialize(array)
      super
      compile_path_patterns
    end

    def compile_path_patterns
      each do |action|
        next unless (path = action['path'])

        regexp = compile_path_pattern(path)
        action['path_regexp'] = regexp
      end
    end

    def compile_path_pattern(path)
      str = Regexp.escape(path)
      str = str.gsub(/\\{\w+\\}/, '[^&=\/]+')
      str = "\\A#{ str }\\z"
      Regexp.new(str)
    end

    def find_request_path(method:, path:)
      return '' unless path && path.size > 0

      path = normalize_path(path)

      action = search_for_an_exact_match(method, path, self)
      return action['path'] if action

      action = search_with_parameter(method, path, self)
      return action['path'] if action

      ''
    end

    def normalize_path(path)
      path = cut_off_query_params(path)
      remove_the_slash_at_the_end2(path)
    end

    def remove_the_slash_at_the_end2(path)
      return path[0..-2] if path[-1] == '/'
      path
    end

    def cut_off_query_params(path)
      path.gsub(/\?.*\z/, '')
    end

    def search_for_an_exact_match(method, path, documentation)
      documentation.find do |action|
        action['path'] == path && action['method'] == method
      end
    end

    def search_with_parameter(method, path, documentation)
      documentation = actions_with_same_method(documentation, method)

      documentation.find do |action|
        next unless regexp = action['path_regexp']
        regexp =~ path
      end
    end

    def actions_with_same_method(documentation, method)
      documentation.find_all do |doc|
        doc['method'] == method
      end
    end
  end
end
