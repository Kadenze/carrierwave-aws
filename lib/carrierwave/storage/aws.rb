# frozen_string_literal: true

require 'aws-sdk-s3'

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

      def cache!(file)
        AWSFile.new(uploader, connection, uploader.cache_path).tap do |aws_file|
          aws_file.store(file)
        end
      end

      def retrieve_from_cache!(identifier)
        AWSFile.new(uploader, connection, uploader.cache_path(identifier))
      end

      def delete_dir!(path)
        # NOTE: noop, because there are no directories on S3
      end

      def clean_cache!(_seconds)
        raise 'use Object Lifecycle Management to clean the cache'
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
