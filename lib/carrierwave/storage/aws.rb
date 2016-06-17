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
        @connection = ::Aws::S3::Resource.new(*credentials)
      end

      def credentials
        creds = uploader.aws_credentials
        new_creds = {}
        creds.each {|k, v| new_creds[k] = v.respond_to?(:call) ? v.call : v}
        [new_creds].compact
      end
    end
  end
end
