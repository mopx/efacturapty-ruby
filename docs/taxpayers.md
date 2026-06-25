# Taxpayers

Look up a taxpayer's name and check digit (DV) by RUC via the PAC.

## Endpoint

`GET /api/v1/Taxpayers/QueryRucDvPac/{taxpayerType}/{ruc}`

## Usage

```ruby
# Natural person (type 1)
client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)

# Legal entity (type 2)
client.taxpayers.query_ruc("NT-8888888", taxpayer_type: 2)
```

## Parameters

| Parameter       | Type    | Required | Description                              |
|-----------------|---------|----------|------------------------------------------|
| `ruc`           | String  | Yes      | Taxpayer RUC number                      |
| `taxpayer_type` | Integer | Yes      | Contributor type: `1` (natural), `2` (legal) |

## Response

| Field             | Type    | Description                              |
|-------------------|---------|------------------------------------------|
| `ruc`             | String  | RUC as registered in PAC                 |
| `dv`              | String  | Check digit (dígito verificador)         |
| `name`            | String  | Taxpayer name                            |
| `isRegisteredDgi` | Boolean | Whether the taxpayer is registered in DGI |
