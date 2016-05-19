# frozen_string_literal: true

require 'aws-sdk-resources'

module CarrierWave
  module Storage
    class AWS < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def self.clear_connection_cache!
        @connection_cache = {}
      end

      def store!(file)
        AWSFile.new(uploader, connection, uploader.store_path).tap do |aws_file|
          aws_file.store(file)
        end
      end

      def retrieve!(identifier)
        AWSFile.new(uploader, connection, uploader.store_path(identifier))
      end

      def connection
        @connection ||= begin
          conn_cache = self.class.connection_cache

          conn_cache[credentials] ||= ::Aws::S3::Resource.new(*credentials)
        end
      end

      def credentials
        creds = uploader.aws_credentials
        creds.each {|k, v| creds[k] = v.respond_to?(:call) ? v.call : v}
        [creds].compact
      end
    end
  end
end
