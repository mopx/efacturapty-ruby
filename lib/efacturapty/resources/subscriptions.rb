module Efacturapty
  module Resources
    # Wraps the /api/v1/Subscriptions endpoints.
    class Subscriptions < BaseResource
      BASE_PATH = "/api/v1/Subscriptions".freeze

      # Paginated list of subscriptions for the authenticated account.
      #
      # @param page [Integer] page number (1-based).
      # @param page_size [Integer] results per page.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response] paginated response with currentPage, pageCount,
      #   pageSize, rowCount, firstRowOnPage, lastRowOnPage, and data array.
      def list(page: nil, page_size: nil, locale: "es-PA")
        params  = { "Page" => page, "PageSize" => page_size }
        headers = { "Accept-Language" => locale }
        get(BASE_PATH, params, headers)
      end
    end
  end
end
