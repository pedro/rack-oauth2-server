module Rack
  module OAuth2
    class Server
      class BaseModel
        def self.collection_name
          raise "Must be implemented!"
        end

        def self.adapter
          @@adapter ||= MongoAdapter.new(Rack::OAuth2::Server.options.database)
        end

        def self.first(conditions)
          adapter.first(collection_name, conditions)
        end

        def self.insert(fields)
          adapter.insert(collection_name, fields)
        end

        def self.update(conditions, fields)
          adapter.update(collection_name, conditions, fields)
        end

        def self.delete_all
          adapter.delete_all(collection_name)
        end
      end
    end
  end
end
