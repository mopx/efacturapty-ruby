module Efacturapty
  module Resources
    # Wraps the /api/v1/Invoices endpoints.
    #
    # Payloads are passed as plain Ruby hashes and mapped directly to the DGI
    # InvoiceRequest JSON structure. See the API docs for the full schema.
    # rubocop:disable Metrics/ClassLength
    class Invoices < BaseResource
      BASE_PATH = "/api/v1/Invoices".freeze

      # Default Accept-Language sent by the official API docs/examples.
      DEFAULT_LOCALE = "es-PA".freeze

      # Create and authorize an invoice via the PAC.
      #
      # @param invoice_hash [Hash] DGI InvoiceRequest payload.
      # @param include_qr [Boolean] include QR image in response.
      # @param include_xml [Boolean] include raw XML in response.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def create(invoice_hash, include_qr: false, include_xml: false, locale: DEFAULT_LOCALE)
        params = {}
        params["qr"]  = true if include_qr
        params["xml"] = true if include_xml
        post(BASE_PATH, invoice_hash, params, accept_language(locale))
      end

      # Create an invoice from a pre-built DGI XML string.
      #
      # @param xml_string [String] the full DGI XML document.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def create_from_xml(xml_string, locale: DEFAULT_LOCALE)
        headers = accept_language(locale).merge("Content-Type" => "application/xml")
        post("#{BASE_PATH}/CreateInvoiceFromXml", xml_string, {}, headers)
      end

      # Paginated list of invoices for the authenticated taxpayer.
      #
      # @param filters [Hash] optional filter/option keys (per the official API):
      #   date_from, date_to (date-time strings), ruc, name,
      #   status (one or more of: pending, authorized, canceled, error),
      #   environment (Integer, deprecated by the API — accepted but discouraged),
      #   page (Integer), page_size (Integer),
      #   locale (String, Accept-Language header, default "es-PA").
      # @return [Response] paginated response: data (array of Transaction),
      #   currentPage, pageCount, pageSize, rowCount, firstRowOnPage, lastRowOnPage.
      def list(filters = {})
        filters = Hash(filters).dup
        sym_locale = filters.delete(:locale)
        str_locale = filters.delete("locale")
        locale   = sym_locale || str_locale || DEFAULT_LOCALE
        params   = camelize_params(filters)
        get(BASE_PATH, params, accept_language(locale))
      end

      # Fetch the authorization protocol and QR for an invoice by CUFE.
      #
      # @param cufe [String] 66-character CUFE.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def authorization(cufe, locale: DEFAULT_LOCALE)
        get("#{BASE_PATH}/Authorization/#{cufe}", {}, accept_language(locale))
      end

      # Admin: fetch authorization for any taxpayer's invoice by CUFE.
      #
      # @param cufe [String] 66-character CUFE.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def authorization_admin(cufe, locale: DEFAULT_LOCALE)
        get("#{BASE_PATH}/AuthorizationAdmin/#{cufe}", {}, accept_language(locale))
      end

      # Retrieve the QR image data (Base64) for an invoice by CUFE.
      #
      # @param cufe [String] 66-character CUFE.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def qr_image(cufe, locale: DEFAULT_LOCALE)
        get("#{BASE_PATH}/GetQrImage/#{cufe}", {}, accept_language(locale))
      end

      # Retrieve the invoice XML from DGI by CUFE.
      #
      # Sends "Accept: application/xml" so the API returns the raw XML instead
      # of its default JSON body (events + xmlRaw).
      #
      # @param cufe [String] 66-character CUFE.
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [String] raw XML bytes.
      def xml_from_dgi(cufe, locale: DEFAULT_LOCALE)
        headers = accept_language(locale).merge("Accept" => "application/xml")
        get_raw("#{BASE_PATH}/GetXmlFromDGI/#{cufe}", {}, headers)
      end

      # Retrieve the processing result for an invoice (taxpayer view).
      #
      # @param invoice_id [String]
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def taxpayer_response(invoice_id, locale: DEFAULT_LOCALE)
        get("#{BASE_PATH}/GetTaxpayerInvoiceResponse/#{invoice_id}", {}, accept_language(locale))
      end

      # Fetch the detail of an invoice by its internal ID.
      #
      # @param cufe_id [String]
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def find(cufe_id, locale: DEFAULT_LOCALE)
        get("#{BASE_PATH}/id/#{cufe_id}", {}, accept_language(locale))
      end

      # Download the CAFE (invoice representation) as a PDF binary.
      #
      # @param cufe_id [String]
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [String] raw PDF bytes.
      def cafe_file(cufe_id, locale: DEFAULT_LOCALE)
        get_raw("#{BASE_PATH}/#{cufe_id}/cafe-file", {}, accept_language(locale))
      end

      # Download the invoice as an XML binary.
      #
      # @param cufe_id [String]
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [String] raw XML bytes.
      def xml_file(cufe_id, locale: DEFAULT_LOCALE)
        get_raw("#{BASE_PATH}/#{cufe_id}/xml-file", {}, accept_language(locale))
      end

      # Get the HTML representation of the invoice (CAFE HTML).
      #
      # @param cufe_id [String]
      # @param cafe_format [String] optional thermal-printer format:
      #   "user_default", "eighty_mm", or "eighty_mm_lite".
      # @param locale [String] Accept-Language header (default "es-PA").
      # @return [Response]
      def html_cafe(cufe_id, cafe_format: nil, locale: DEFAULT_LOCALE)
        params = { "cafeFormat" => cafe_format }
        get("#{BASE_PATH}/#{cufe_id}/html-cafe", params, accept_language(locale))
      end

      # ---------------------------------------------------------------------------
      # Document-type helpers
      # These build the required DGI fields for each document type and delegate
      # to {#create}. All keyword options accepted by {#create} are forwarded.
      # ---------------------------------------------------------------------------

      # Nota de Crédito referente a una o varias FE (tipoDocumento "04").
      # The DGI requires a reference to the original invoice's CUFE (field B606).
      #
      # @param payload [Hash] base InvoiceRequest payload (same structure as {#create}).
      # @param referenced_cufe [String] CUFE of the invoice being corrected.
      # @param referenced_date [String] issue date of that invoice (YYYY-MM-DD).
      # @return [Response]
      def create_credit_note(payload, referenced_cufe:, referenced_date:, **opts)
        create(
          with_document_type(payload, "04", referenced_cufe, referenced_date),
          **opts
        )
      end

      # Nota de Débito referente a una o varias FE (tipoDocumento "05").
      # Same structure as {#create_credit_note} but for debit notes.
      #
      # @param payload [Hash] base InvoiceRequest payload.
      # @param referenced_cufe [String] CUFE of the invoice being corrected.
      # @param referenced_date [String] issue date of that invoice (YYYY-MM-DD).
      # @return [Response]
      def create_debit_note(payload, referenced_cufe:, referenced_date:, **opts)
        create(
          with_document_type(payload, "05", referenced_cufe, referenced_date),
          **opts
        )
      end

      # Nota de Crédito genérica (tipoDocumento "06").
      # No reference to a specific FE is required.
      #
      # @param payload [Hash] base InvoiceRequest payload.
      # @return [Response]
      def create_generic_credit_note(payload, **opts)
        create(with_tipo_documento(payload, "06"), **opts)
      end

      # Nota de Débito genérica (tipoDocumento "07").
      # No reference to a specific FE is required.
      #
      # @param payload [Hash] base InvoiceRequest payload.
      # @return [Response]
      def create_generic_debit_note(payload, **opts)
        create(with_tipo_documento(payload, "07"), **opts)
      end

      # Convert snake_case filter keys to the PascalCase query params the API expects.
      # Matches the query parameters documented for GET /api/v1/Invoices — the API
      # does not support document_number, billing_point, branch_office_code,
      # document_type_codes, cufe, or created_by, despite earlier gem versions
      # having offered them.
      PARAM_MAP = {
        "date_from" => "DateFrom",
        "date_to" => "DateTo",
        "ruc" => "Ruc",
        "name" => "Name",
        "page_size" => "PageSize",
        "page" => "Page",
        "status" => "Status",
        "environment" => "Environment"
      }.freeze

      private

      def accept_language(locale)
        { "Accept-Language" => locale }
      end

      # Silently drops any filter key the API doesn't document — the API returns
      # no error for unknown query params, so passing them through would look
      # like it worked while being ignored server-side.
      def camelize_params(hash)
        hash.each_with_object({}) do |(k, v), out|
          mapped = PARAM_MAP[k.to_s]
          out[mapped] = v if mapped
        end
      end

      # Sets tipoDocumento and injects a documentosFiscalesReferenciados array
      # for referenced (tipos 04/05) credit/debit notes.
      def with_document_type(payload, tipo, cufe, date)
        with_tipo_documento(payload, tipo).tap do |p|
          refs = [build_fe_reference(cufe: cufe, date: date)]
          p["datosGenerales"] = (p["datosGenerales"] || {}).merge(
            "documentosFiscalesReferenciados" => refs
          )
        end
      end

      # Sets only tipoDocumento (for generic tipos 06/07 that need no CUFE reference).
      def with_tipo_documento(payload, tipo)
        dat_gen = (payload["datosGenerales"] || {}).merge("tipoDocumento" => tipo)
        payload.merge("datosGenerales" => dat_gen)
      end

      # Builds the DGI reference structure that points back to the original FE.
      # Ficha Técnica v1.10 field B606: cufeReferenciado inside gDFRefFERequest.
      def build_fe_reference(cufe:, date:)
        {
          "fechaEmisionDocumentoReferenciado" => date,
          "informacionReferencia" => {
            "informacionReferencia" => { "cufeReferenciado" => cufe }
          }
        }
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
