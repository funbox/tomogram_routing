require 'multi_json'

module TomogramRouting
  class Tomogram < Array
    def self.craft(docs)
      new(MultiJson.load(docs).inject([]) do |res, doc|
        res.push(Request.new.merge(doc))
      end)
    end

    def find_request(method:, path:)
      find do |doc|
        path = find_request_path(method: method, path: path)
        doc['path'] == path && doc['method'] == method
      end
    end

    private

    def find_request_path(method:, path:)
      return '' unless path && path.size > 0

      path = remove_the_slash_at_the_end2(path)

      action = search_for_an_exact_match(method, path, self)
      return action['path'] if action

      action = search_with_parameter(method, path, self)
      return action['path'] if action && action.first

      ''
    end

    def remove_the_slash_at_the_end2(path)
      return path[0..-2] if path[-1] == '/'
      path
    end

    def search_for_an_exact_match(method, path, documentation)
      documentation.find do |action|
        action['path'] == path && action['method'] == method
      end
    end

    def search_with_parameter(method, path, documentation)
      documentation = actions_with_same_method(documentation, method)
      sought_for_path = path.split('/')

      documentation.map do |action|
        current_path = action['path'].split('/')
        next unless sought_for_path.size == current_path.size
        next unless match(sought_for_path, current_path)
        return action
      end
    end

    def actions_with_same_method(documentation, method)
      documentation.find_all do |doc|
        doc['method'] == method
      end
    end

    def match(sought_for_path, current_path)
      sought_for_path.zip(current_path).all? do |p|
        p[0] == p[1] || (p[1][0] == '{' && p[1][-1] == '}')
      end
    end
  end
end
