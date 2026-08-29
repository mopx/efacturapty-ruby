require_relative "constants"
require_relative "errors"

module Efacturapty
  # Client-side pre-flight validation for {Resources::Invoices#create} payloads.
  #
  # Emitting an invoice is a slow, side-effecting call to a PAC — a bad request
  # wastes a round-trip and returns an opaque HTTP 400/422. This validator
  # catches only the mistakes the official docs make unambiguous: it is
  # deliberately *permissive*, not authoritative. Fields the API can default
  # (numeroDocumento, fechaEmision, puntoFacturacion, totals, etc.) are never
  # required here even where the docs show a "required" badge, and anything
  # not covered below (cross-field math, ITBMS calculation, business rules) is
  # left entirely to the API to enforce.
  #
  # See docs/invoices.md for the field reference this validator is derived from.
  # rubocop:disable-next Metrics/ClassLength
  class InvoiceValidator
    TIPO_EMISION = %w[01 02 03 04].freeze
    TIPO_OPERACION = %w[1 2].freeze
    DESTINO_OPERACION = %w[1 2].freeze
    TIPO_TRANSACCION_VENTA = %w[1 2 3 4].freeze
    TIPO_SUCURSAL = %w[1 2].freeze
    TIEMPO_PAGO = %w[1 2 3].freeze
    ITBMS_RATES = %w[00 01 02 03].freeze
    REFERENCED_NOTE_TYPES = %w[04 05].freeze
    PUNTO_FACTURACION_PATTERN = /\A\d{3}\z/.freeze

    # datosGenerales fields validated as simple closed enums.
    DATOS_GENERALES_ENUMS = {
      "tipoEmision" => TIPO_EMISION,
      "tipoDocumento" => Constants::DOCUMENT_TYPES.keys,
      "naturalezaOperacion" => Constants::OPERATION_NATURES.keys,
      "tipoOperacion" => TIPO_OPERACION,
      "destinoOperacion" => DESTINO_OPERACION,
      "tipoTransaccionVenta" => TIPO_TRANSACCION_VENTA,
      "tipoSucursal" => TIPO_SUCURSAL
    }.freeze

    # listaItems[] fields required on every line item.
    ITEM_REQUIRED_FIELDS = %w[numeroSecuenciaItem descripcionProductoServicio
                              cantidadProductoServicio grupoPrecios grupoITBMS].freeze

    class << self
      # @param payload [Hash] the InvoiceRequest payload passed to #create.
      # @raise [ValidationError] if any check fails.
      def validate!(payload)
        errors = errors_for(payload)
        raise ValidationError, errors unless errors.empty?
      end

      # @param payload [Hash] the InvoiceRequest payload passed to #create.
      # @return [Array<String>] human-readable validation errors, empty if none.
      def errors_for(payload)
        new(payload).errors
      end
    end

    def initialize(payload)
      @payload = payload.is_a?(Hash) ? payload : {}
      @errors  = []
    end

    def errors
      check_top_level
      check_datos_generales
      check_lista_items
      check_totales
      @errors
    end

    private

    def check_top_level
      if @payload.empty?
        @errors << "payload must be a non-empty Hash"
        return
      end

      require_present(@payload, "datosGenerales", Hash)
      require_present(@payload, "totales", Hash)
      items = fetch(@payload, "listaItems")
      return if items.is_a?(Array) && !items.empty?

      @errors << "listaItems is required and must be a non-empty array"
    end

    def check_datos_generales
      datos = fetch(@payload, "datosGenerales")
      return unless datos.is_a?(Hash)

      require_present(datos, "informacionReceptor", Hash)
      DATOS_GENERALES_ENUMS.each { |field, allowed| check_enum(datos, field, allowed) }
      check_punto_facturacion(datos)
      check_factura_exportacion(datos)
      check_referenced_note(datos)
    end

    def check_punto_facturacion(datos)
      value = fetch(datos, "puntoFacturacion")
      return if value.nil?

      str = value.to_s
      return if str.match?(PUNTO_FACTURACION_PATTERN) && str != "000"

      @errors << "datosGenerales.puntoFacturacion must be 3 digits and not \"000\" (got #{value.inspect})"
    end

    def check_factura_exportacion(datos)
      return unless fetch(datos, "destinoOperacion").to_s == "2"
      return if present?(fetch(datos, "facturaExportacion"))

      @errors << "datosGenerales.facturaExportacion is required when destinoOperacion is 2 (Extranjero)"
    end

    def check_referenced_note(datos)
      return unless REFERENCED_NOTE_TYPES.include?(fetch(datos, "tipoDocumento").to_s)

      refs = fetch(datos, "documentosFiscalesReferenciados")
      return if refs.is_a?(Array) && !refs.empty?

      @errors << "datosGenerales.documentosFiscalesReferenciados is required when tipoDocumento " \
                 "is 04 or 05 (use create_credit_note/create_debit_note, or supply it directly)"
    end

    def check_lista_items
      items = fetch(@payload, "listaItems")
      return unless items.is_a?(Array)

      items.each_with_index { |item, idx| check_item(item, idx) }
    end

    def check_item(item, idx)
      unless item.is_a?(Hash)
        @errors << "listaItems[#{idx}] must be an object"
        return
      end

      check_item_required_fields(item, idx)
      check_item_numero_secuencia(item, idx)
      check_item_descripcion(item, idx)
      check_item_grupo_itbms(item, idx)
    end

    def check_item_required_fields(item, idx)
      ITEM_REQUIRED_FIELDS.each do |field|
        next if present?(fetch(item, field))

        @errors << "listaItems[#{idx}].#{field} is required"
      end
    end

    def check_item_numero_secuencia(item, idx)
      value = fetch(item, "numeroSecuenciaItem")
      return if value.nil?

      int_value = Integer(value.to_s, exception: false)
      return if int_value&.between?(1, 9999)

      @errors << "listaItems[#{idx}].numeroSecuenciaItem must be an integer between 1 and 9999 " \
                 "(got #{value.inspect})"
    end

    def check_item_descripcion(item, idx)
      value = fetch(item, "descripcionProductoServicio")
      return if value.nil?

      return if value.to_s.length.between?(2, 500)

      @errors << "listaItems[#{idx}].descripcionProductoServicio must be 2-500 characters " \
                 "(got #{value.to_s.length} chars)"
    end

    def check_item_grupo_itbms(item, idx)
      grupo = fetch(item, "grupoITBMS")
      return unless grupo.is_a?(Hash)

      rate = fetch(grupo, "tasaITBMSAplicable")
      return if rate.nil? || ITBMS_RATES.include?(rate.to_s)

      @errors << "listaItems[#{idx}].grupoITBMS.tasaITBMSAplicable must be one of " \
                 "#{ITBMS_RATES.join(', ')} (got #{rate.inspect})"
    end

    def check_totales
      totales = fetch(@payload, "totales")
      return unless totales.is_a?(Hash)

      require_present(totales, "tiempoPago")
      check_enum(totales, "tiempoPago", TIEMPO_PAGO)
      unless fetch(totales, "grupoFormasPago").is_a?(Array) && !fetch(totales, "grupoFormasPago").empty?
        @errors << "totales.grupoFormasPago is required and must be a non-empty array"
      end
      check_grupo_informacion_pago(totales)
    end

    def check_grupo_informacion_pago(totales)
      return unless %w[2 3].include?(fetch(totales, "tiempoPago").to_s)

      info = fetch(totales, "grupoInformacionPago")
      return if present?(info)

      @errors << "totales.grupoInformacionPago is required when tiempoPago is 2 or 3 (Crédito/Mixto)"
    end

    # --- generic helpers ---------------------------------------------------

    def require_present(hash, field, klass = nil)
      value = fetch(hash, field)
      if present?(value)
        @errors << "#{field} must be a #{klass}" if klass && !value.is_a?(klass)
      else
        @errors << "#{field} is required"
      end
    end

    def check_enum(hash, field, allowed)
      value = fetch(hash, field)
      return if value.nil? || allowed.include?(value.to_s)

      @errors << "#{field} must be one of #{allowed.join(', ')} (got #{value.inspect})"
    end

    def present?(value)
      return false if value.nil?
      return false if value.respond_to?(:empty?) && value.empty?

      true
    end

    # Tolerates both string and symbol keys, since payloads may come from
    # either style even though the API itself expects string keys on the wire.
    def fetch(hash, key)
      return nil unless hash.is_a?(Hash)

      hash[key] || hash[key.to_sym]
    end
  end
end
