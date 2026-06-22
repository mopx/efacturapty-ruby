module Efacturapty
  module Resources
    # Wraps the /api/v1/Invoices endpoints.
    #
    # Payloads are passed as plain Ruby hashes and mapped directly to the DGI
    # InvoiceRequest JSON structure. See the API docs for the full schema.
    class Invoices < BaseResource
      BASE_PATH = "/api/v1/Invoices".freeze

      # Create and authorize an invoice via the PAC.
      #
      # @param invoice_hash [Hash] DGI InvoiceRequest payload.
      # @param include_qr [Boolean] include QR image in response.
      # @param include_xml [Boolean] include raw XML in response.
      # @param locale [String] Accept-Language header (default "es").
      # @return [Response]
      def create(invoice_hash, include_qr: false, include_xml: false, locale: "es")
        params = {}
        params["qr"]  = true if include_qr
        params["xml"] = true if include_xml
        headers = { "Accept-Language" => locale }
        post(BASE_PATH, invoice_hash, params, headers)
      end

      # Create an invoice from a pre-built DGI XML string.
      #
      # @param xml_string [String] the full DGI XML document.
      # @param locale [String] Accept-Language header.
      # @return [Response]
      def create_from_xml(xml_string, locale: "es")
        headers = { "Accept-Language" => locale, "Content-Type" => "application/xml" }
        post("#{BASE_PATH}/CreateInvoiceFromXml", xml_string, {}, headers)
      end

      # Paginated list of invoices for the authenticated taxpayer.
      #
      # @param filters [Hash] optional filter/option keys:
      #   date_from, date_to, ruc, name, document_number, billing_point,
      #   branch_office_code, status, cufe, environment, created_by,
      #   document_type_codes (Array), page (Integer), page_size (Integer),
      #   locale (String, Accept-Language header, default "es").
      # @return [Response]
      def list(filters = {})
        filters = Hash(filters).dup
        sym_locale = filters.delete(:locale)
        str_locale = filters.delete("locale")
        locale   = sym_locale || str_locale || "es"
        headers  = { "Accept-Language" => locale }
        params   = camelize_params(filters)
        get(BASE_PATH, params, headers)
      end

      # Fetch the authorization protocol and QR for an invoice by CUFE.
      #
      # @param cufe [String]
      # @return [Response]
      def authorization(cufe)
        get("#{BASE_PATH}/Authorization/#{cufe}")
      end

      # Admin: fetch authorization for any taxpayer's invoice by CUFE.
      #
      # @param cufe [String]
      # @return [Response]
      def authorization_admin(cufe)
        get("#{BASE_PATH}/AuthorizationAdmin/#{cufe}")
      end

      # Retrieve the QR image data (Base64) for an invoice by CUFE.
      #
      # @param cufe [String]
      # @return [Response]
      def qr_image(cufe)
        get("#{BASE_PATH}/GetQrImage/#{cufe}")
      end

      # Retrieve the invoice XML from DGI by CUFE.
      #
      # @param cufe [String]
      # @return [String] raw XML bytes.
      def xml_from_dgi(cufe)
        get_raw("#{BASE_PATH}/GetXmlFromDGI/#{cufe}")
      end

      # Retrieve the processing result for an invoice (taxpayer view).
      #
      # @param invoice_id [String]
      # @return [Response]
      def taxpayer_response(invoice_id)
        get("#{BASE_PATH}/GetTaxpayerInvoiceResponse/#{invoice_id}")
      end

      # Fetch the detail of an invoice by CUFE ID (taxpayer view).
      #
      # @param cufe_id [String]
      # @return [Response]
      def find(cufe_id)
        get("#{BASE_PATH}/id/#{cufe_id}")
      end

      # Download the CAFE (invoice representation) as a PDF binary.
      #
      # @param cufe_id [String]
      # @return [String] raw PDF bytes.
      def cafe_file(cufe_id)
        get_raw("#{BASE_PATH}/#{cufe_id}/cafe-file")
      end

      # Download the invoice as an XML binary.
      #
      # @param cufe_id [String]
      # @return [String] raw XML bytes.
      def xml_file(cufe_id)
        get_raw("#{BASE_PATH}/#{cufe_id}/xml-file")
      end

      # Get the HTML representation of the invoice (CAFE HTML).
      #
      # @param cufe_id [String]
      # @return [Response]
      def html_cafe(cufe_id)
        get("#{BASE_PATH}/#{cufe_id}/html-cafe")
      end

      # Send the invoice to the taxpayer's email.
      #
      # @param invoice_id [String]
      # @param email [String] optional override email address.
      # @return [Response]
      def mail_to(invoice_id, email: nil)
        body = email ? { "email" => email } : {}
        post("#{BASE_PATH}/#{invoice_id}/mailto", body)
      end

      # Convert snake_case filter keys to the PascalCase query params the API expects.
      PARAM_MAP = {
        "date_from" => "DateFrom",
        "date_to" => "DateTo",
        "ruc" => "Ruc",
        "name" => "Name",
        "document_number" => "DocumentNumber",
        "billing_point" => "BillingPoint",
        "branch_office_code" => "BranchOfficeCode",
        "page_size" => "PageSize",
        "page" => "Page",
        "status" => "Status",
        "document_type_codes" => "DocumentTypeCodes",
        "cufe" => "Cufe",
        "environment" => "Environment",
        "created_by" => "CreatedBy"
      }.freeze

      private

      def camelize_params(hash)
        hash.each_with_object({}) do |(k, v), out|
          out[PARAM_MAP.fetch(k.to_s, k.to_s)] = v
        end
      end
    end
  end
end
