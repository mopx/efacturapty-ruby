# Ruby client for Panama's DGI e-invoicing (e-factura / SFEP) system.
# @see https://github.com/mopx/efacturapty-ruby
module Efacturapty
  # DGI reference code tables from Ficha Técnica de Factura Electrónica v1.10.
  # Use these constants instead of magic strings in your integration code.
  #
  #   Efacturapty::Constants::DOCUMENT_TYPES["04"]
  #   # => "Nota de Crédito referente a una o varias FE"
  #
  module Constants
    # B06 – tipoDocumento
    DOCUMENT_TYPES = {
      "01" => "Factura de operación interna",
      "02" => "Factura de importación",
      "03" => "Factura de exportación",
      "04" => "Nota de Crédito referente a una o varias FE",
      "05" => "Nota de Débito referente a una o varias FE",
      "06" => "Nota de Crédito genérica",
      "07" => "Nota de Débito genérica",
      "08" => "Factura de Zona Franca",
      "09" => "Reembolso",
      "10" => "Factura de operación extranjera"
    }.freeze

    # B13 – iTipoOp / naturalezaOperacion
    OPERATION_NATURES = {
      "01" => "Venta",
      "02" => "Exportación",
      "03" => "Re-exportación",
      "04" => "Venta de fuente extranjera",
      "05" => "Servicio de fuente extranjera",
      "10" => "Transferencia/Traspaso",
      "11" => "Devolución",
      "12" => "Consignación",
      "13" => "Remesa",
      "14" => "Entrega gratuita",
      "20" => "Compra",
      "21" => "Importación"
    }.freeze

    # B12 – iTipoOpe: direction of the operation
    OPERATION_DIRECTIONS = {
      1 => "Salida o venta",
      2 => "Entrada o compra"
    }.freeze

    # B14 – iDest: destination of the operation
    DESTINATIONS = {
      1 => "Panamá",
      2 => "Extranjero"
    }.freeze

    # B15 – iFormCAFE: CAFE generation format
    CAFE_FORMATS = {
      1 => "Sin generación de CAFE",
      2 => "Cinta de papel",
      3 => "Papel formato carta"
    }.freeze

    # B16 – iEntCAFE: CAFE delivery method to receptor
    CAFE_DELIVERY_METHODS = {
      1 => "Sin generación de CAFE",
      2 => "CAFE entregado al receptor en papel",
      3 => "CAFE enviado al receptor en formato electrónico"
    }.freeze

    # B17 – dEnvFE: container delivery to receptor
    CONTAINER_DELIVERY = {
      1 => "Normal",
      2 => "Receptor exceptúa al emisor de obligatoriedad de envío"
    }.freeze

    # B18 – iProGen: FE generation process
    GENERATION_PROCESSES = {
      1 => "Sistema de facturación del contribuyente",
      2 => "Generación por tercero contratado",
      3 => "Generación gratuita por tercero proveedor de solución",
      4 => "Generación gratuita por la DGI en página web"
    }.freeze

    # B19 – iTipoTranVenta: type of sales transaction
    SALE_TRANSACTION_TYPES = {
      1 => "Contado",
      2 => "Crédito"
    }.freeze

    # tipoReceptor: receptor classification
    RECEPTOR_TYPES = {
      "01" => "Contribuyente",
      "02" => "Consumidor final",
      "03" => "Gobierno",
      "04" => "Extranjero"
    }.freeze

    # C401 – dTasaITBMS: ITBMS (VAT) rate
    ITBMS_RATES = {
      "00" => "0% (exento)",
      "01" => "7%",
      "02" => "10%",
      "03" => "15%"
    }.freeze

    # D301 – iFormaPago: payment method
    PAYMENT_METHODS = {
      "01" => "Crédito",
      "02" => "Contado",
      "03" => "Tarjeta Crédito",
      "04" => "Tarjeta Débito",
      "05" => "Tarjeta Fidelización",
      "06" => "Vale",
      "07" => "Tarjeta de Regalo",
      "99" => "Otro"
    }.freeze
  end
end
