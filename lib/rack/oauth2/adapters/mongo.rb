require "mongo"
require "openssl"
require "rack/oauth2/server/errors"
require "rack/oauth2/server/utils"

module Rack
  module OAuth2
    class Server
      class MongoAdapter
        attr_accessor :db

        def initialize(db)
          raise "No database Configured. You must configure it using Server.options.database = Mongo::Connection.new()[db_name]" unless db
          raise "You set Server.database to #{Server.database.class}, should be a Mongo::DB object" unless Mongo::DB === db
          @db = db
        end

        def first(collection_name, conditions)
          collection_for(collection_name).find_one(conditions)
        end

        def insert(collection_name, fields)
          collection_for(collection_name).insert(fields)
        end

        def update(collection_name, conditions, fields)
          collection_for(collection_name).update(conditions, fields, :safe => true)
        end

        def delete_all(collection_name)
          collection_for(collection_name).drop
        end

        def collection_for(collection_name)
          prefix = Server.options[:collection_prefix]
          db["#{prefix}.#{collection_name}"]
        end
      end

      class << self
        # Create new instance of the klass and populate its attributes.
        def new_instance(klass, fields)
          return unless fields
          instance = klass.new
          fields.each do |name, value|
            instance.instance_variable_set :"@#{name}", value
          end
          instance
        end

        # Long, random and hexy.
        def secure_random
          OpenSSL::Random.random_bytes(32).unpack("H*")[0]
        end
        
        # @private
        def create_indexes(&block)
          if block
            @create_indexes ||= []
            @create_indexes << block
          elsif @create_indexes
            @create_indexes.each do |block|
              block.call
            end
            @create_indexes = nil
          end
        end
 
        # A Mongo::DB object.
        def database
          @database ||= Server.options.database
          raise "No database Configured. You must configure it using Server.options.database = Mongo::Connection.new()[db_name]" unless @database
          raise "You set Server.database to #{Server.database.class}, should be a Mongo::DB object" unless Mongo::DB === @database
          @database
        end
      end
 
    end
  end
end
