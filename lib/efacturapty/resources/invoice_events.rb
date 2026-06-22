module Efacturapty
  module Resources
    # Wraps the /api/v1/InvoiceEvents endpoints.
    class InvoiceEvents < BaseResource
      BASE_PATH = "/api/v1/InvoiceEvents".freeze

      # Cancel (void/annul) an authorized electronic invoice by CUFE.
      #
      # @param cufe [String] the CUFE of the invoice to cancel.
      # @param reason [String] the reason for cancellation.
      # @return [Response]
      def cancel(cufe:, reason: nil)
        body = { "cufe" => cufe, "cancellationReason" => reason }
        post("#{BASE_PATH}/CreateCancellation", body)
      end
    end
  end
end
