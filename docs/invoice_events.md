# Invoice Events

Cancel (void/annul) an authorized electronic invoice by CUFE, and query the events recorded
against an invoice.

## Cancel an invoice

`POST /api/v1/InvoiceEvents/CreateCancellation`

```ruby
resp = client.invoice_events.cancel(
  cufe:   "CUFE-xxxx...",
  reason: "Error en los datos del receptor"
)
```

### Parameters

| Parameter | Type   | Required | Description                             |
|-----------|--------|----------|------------------------------------------|
| `cufe`    | String | Yes      | CUFE of the invoice to cancel           |
| `reason`  | String | Yes      | Reason for the cancellation             |

The request body sent to the API is `{ "cufe" => cufe, "cancellationReason" => reason }`.

### Response

On success, returns an `Efacturapty::Response` wrapping an array of:

| Field     | Type   | Description                                          |
|-----------|--------|-------------------------------------------------------|
| `codigo`  | String | Result code                                          |
| `mensaje` | String | Result message, e.g. `"Evento registrado con éxito"` |

### Error codes

| Code   | Meaning                                                      |
|--------|----------------------------------------------------------------|
| `0622` | A cancellation event already exists for this document          |
| `0623` | DV does not correspond to the referenced invoice               |
| `0624` | RUC does not correspond to the referenced invoice               |
| `0625` | Elapsed time does not allow cancellation — **must be less than 182 hours** after issuance |
| `0626` | Taxpayer type does not correspond to the referenced invoice     |
| `0627` | Issuer RUC does not correspond to the referenced invoice         |

A `401` is returned if the account isn't authorized to cancel; any other error returns its own
HTTP status with the error message.

## Query invoice events

`GET /api/v1/InvoiceEvents/GetAll/{cufe}`

Returns the list of events recorded against an invoice (cancellations, receiver manifestations,
references, authorizations).

```ruby
resp = client.invoice_events.events("CUFE-xxxx...")

# Filter by event type
resp = client.invoice_events.events("CUFE-xxxx...", event_type: "cancellation")
```

### Parameters

| Parameter    | Type   | Required | Description                                                                     |
|--------------|--------|----------|-----------------------------------------------------------------------------------|
| `cufe`       | String | Yes      | CUFE of the invoice (path parameter)                                             |
| `event_type` | String | No       | Filter: `cancellation`, `receiver-manifestation`, `referenced`, or `authorization` |
| `locale`     | String | No       | `Accept-Language` header (default `"es-PA"`)                                     |

### Response

| Field                    | Type            | Description                              |
|--------------------------|-----------------|-------------------------------------------|
| `events`                 | Array of Object | The invoice's events                     |
| `events[].eventCode`     | Integer         |                                            |
| `events[].invoiceEventType` | String       | e.g. `"cancellation"`, `"authorization"`  |
| `events[].cancellationReason` | String     | Present for cancellation events           |
| `events[].manifestationReason` | String    | Present for receiver-manifestation events |
| `events[].referencedCufe` | String         | Present for referenced (credit/debit note) events |
| `events[].authorizationProtocol` | String  | Present for authorization events          |
| `events[].xmlRaw`        | String          | Raw XML for the event, when available     |
