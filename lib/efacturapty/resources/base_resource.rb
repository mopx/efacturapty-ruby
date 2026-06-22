module Efacturapty
  module Resources
    # Shared helpers for all resource classes.
    class BaseResource
      def initialize(connection)
        @conn = connection
      end

      private

      def get(path, params = {}, headers = {})
        @conn.get(path, compact(params), headers)
      end

      def post(path, body = {}, params = {}, headers = {})
        @conn.post(path, body, compact(params), headers)
      end

      def get_raw(path, params = {}, headers = {})
        @conn.get_raw(path, compact(params), headers)
      end

      # Remove nil/empty values from a params hash so they aren't serialized.
      def compact(hash)
        hash.compact
      end
    end
  end
end
