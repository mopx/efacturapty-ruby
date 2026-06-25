module Efacturapty
  module Resources
    # Wraps the /api/v1/Taxpayers endpoints.
    class Taxpayers < BaseResource
      BASE_PATH = "/api/v1/Taxpayers".freeze

      # Look up a taxpayer's name and check digit (DV) by RUC via the PAC.
      #
      # @param ruc [String] taxpayer RUC number.
      # @param taxpayer_type [Integer] contributor type: 1 (natural) or 2 (legal).
      # @return [Response] with ruc, dv, name, isRegisteredDgi fields.
      def query_ruc(ruc, taxpayer_type:)
        get("#{BASE_PATH}/QueryRucDvPac/#{taxpayer_type}/#{ruc}")
      end
    end
  end
end
