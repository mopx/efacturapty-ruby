# Constants

`Efacturapty::Constants` provides the DGI reference code tables from the
*Ficha Técnica de Factura Electrónica v1.10* as Ruby constants.

Use them instead of magic strings in your application code:

```ruby
Efacturapty::Constants::DOCUMENT_TYPES["04"]
# => "Nota de Crédito referente a una o varias FE"

Efacturapty::Constants::ITBMS_RATES["01"]
# => "7%"
```

## DOCUMENT_TYPES (B06 – tipoDocumento)

| Code | Description |
|------|-------------|
| `"01"` | Factura de operación interna |
| `"02"` | Factura de importación |
| `"03"` | Factura de exportación |
| `"04"` | Nota de Crédito referente a una o varias FE |
| `"05"` | Nota de Débito referente a una o varias FE |
| `"06"` | Nota de Crédito genérica |
| `"07"` | Nota de Débito genérica |
| `"08"` | Factura de Zona Franca |
| `"09"` | Reembolso |
| `"10"` | Factura de operación extranjera |

## OPERATION_NATURES (B13 – naturalezaOperacion)

| Code | Description |
|------|-------------|
| `"01"` | Venta |
| `"02"` | Exportación |
| `"03"` | Re-exportación |
| `"04"` | Venta de fuente extranjera |
| `"05"` | Servicio de fuente extranjera |
| `"10"` | Transferencia/Traspaso |
| `"11"` | Devolución |
| `"12"` | Consignación |
| `"13"` | Remesa |
| `"14"` | Entrega gratuita |
| `"20"` | Compra |
| `"21"` | Importación |

## OPERATION_DIRECTIONS (B12 – iTipoOpe)

| Code | Description |
|------|-------------|
| `1` | Salida o venta |
| `2` | Entrada o compra |

## DESTINATIONS (B14 – iDest)

| Code | Description |
|------|-------------|
| `1` | Panamá |
| `2` | Extranjero |

## CAFE_FORMATS (B15 – iFormCAFE)

| Code | Description |
|------|-------------|
| `1` | Sin generación de CAFE |
| `2` | Cinta de papel |
| `3` | Papel formato carta |

## CAFE_DELIVERY_METHODS (B16 – iEntCAFE)

| Code | Description |
|------|-------------|
| `1` | Sin generación de CAFE |
| `2` | CAFE entregado al receptor en papel |
| `3` | CAFE enviado al receptor en formato electrónico |

## CONTAINER_DELIVERY (B17 – dEnvFE)

| Code | Description |
|------|-------------|
| `1` | Normal |
| `2` | Receptor exceptúa al emisor de obligatoriedad de envío |

## GENERATION_PROCESSES (B18 – iProGen)

| Code | Description |
|------|-------------|
| `1` | Sistema de facturación del contribuyente |
| `2` | Generación por tercero contratado |
| `3` | Generación gratuita por tercero proveedor de solución |
| `4` | Generación gratuita por la DGI en página web |

## SALE_TRANSACTION_TYPES (B19 – iTipoTranVenta)

| Code | Description |
|------|-------------|
| `1` | Contado |
| `2` | Crédito |

## RECEPTOR_TYPES (tipoReceptor)

| Code | Description |
|------|-------------|
| `"01"` | Contribuyente |
| `"02"` | Consumidor final |
| `"03"` | Gobierno |
| `"04"` | Extranjero |

## ITBMS_RATES (C401 – dTasaITBMS)

| Code | Rate |
|------|------|
| `"00"` | 0% (exento) |
| `"01"` | 7% |
| `"02"` | 10% |
| `"03"` | 15% |

## PAYMENT_METHODS (D301 – iFormaPago)

| Code | Description |
|------|-------------|
| `"01"` | Crédito |
| `"02"` | Contado |
| `"03"` | Tarjeta Crédito |
| `"04"` | Tarjeta Débito |
| `"05"` | Tarjeta Fidelización |
| `"06"` | Vale |
| `"07"` | Tarjeta de Regalo |
| `"99"` | Otro |
