module Efacturapty
  module Resources
    # Wraps the /api/v1/InvoiceEvents endpoints.
    class InvoiceEvents < BaseResource
      BASE_PATH = "/api/v1/InvoiceEvents".freeze

      # Default Accept-Language sent by the official API docs/examples.
      DEFAULT_LOCALE = "es-PA".freeze

      # Cancel (void/annul) an authorized electronic invoice by CUFE.
      #
      # @param cufe [String] the CUFE of the invoice to cancel.
      # @param reason [String] the reason for cancellation.
      # @return [Response]
      def cancel(cufe:, reason:)
        body = { "cufe" => cufe, "cancellationReason" => reason }
        post("#{BASE_PATH}/CreateCancellation", body)
      end

      # List the events recorded for an invoice by CUFE (cancellation, receiver
      # manifestation, references, authorization).
      #
      # @param cufe [String] the CUFE of the invoice.
      # @param event_type [String, nil] optional filter: "cancellation",
      #   "receiver-manifestation", "referenced", or "authorization".
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def events(cufe, event_type: nil, locale: DEFAULT_LOCALE)
        params  = { "eventType" => event_type }
        headers = { "Accept-Language" => locale }
        get("#{BASE_PATH}/GetAll/#{cufe}", params, headers)
      end
    end
  end
end
