module Efacturapty
  module Resources
    # Wraps the /api/v1/Catalogs reference-data endpoints.
    class Catalogs < BaseResource
      BASE_PATH = "/api/v1/Catalogs".freeze

      # List of countries (DGI catalog).
      # @return [Response]
      def countries
        get("#{BASE_PATH}/countries")
      end

      # List of currencies.
      # @return [Response]
      def currencies
        get("#{BASE_PATH}/currencies")
      end

      # Location data: distrito, provincia, corregimiento.
      # @return [Response]
      def locations
        get("#{BASE_PATH}/locations")
      end

      # Product/service coding — family level (CPBS fams).
      # @return [Response]
      def cpbs_families
        get("#{BASE_PATH}/CPBSfams")
      end

      # Product/service coding — segment level (CPBS segs).
      # @return [Response]
      def cpbs_segments
        get("#{BASE_PATH}/CPBSsegs")
      end
    end
  end
end
