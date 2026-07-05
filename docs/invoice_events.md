# Invoice Events

Cancel (void/annul) an authorized electronic invoice by CUFE.

## Endpoint

`POST /api/v1/InvoiceEvents/CreateCancellation`

## Usage

```ruby
resp = client.invoice_events.cancel(
  cufe:   "CUFE-xxxx...",
  reason: "Error en los datos del receptor"
)
```

## Parameters

| Parameter | Type   | Required | Description                                  |
|-----------|--------|----------|-----------------------------------------------|
| `cufe`    | String | Yes      | CUFE of the invoice to cancel                |
| `reason`  | String | No       | Free-text reason for the cancellation        |

The request body sent to the API is `{ "cufe" => cufe, "cancellationReason" => reason }`.

## Response

Returns an `Efacturapty::Response`. The only field verified by this gem's test suite is `id`
(the cancellation event ID) — there is no official Stoplight PDF reference for this endpoint in
`efacturapty-docs/` (unlike the Invoices endpoints), so the rest of the response shape hasn't been
independently confirmed. Treat any other keys the live API returns as provisional until verified.
