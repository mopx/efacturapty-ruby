# Subscriptions

Retrieves subscription data for the authenticated account — plan details, transaction usage, and validity dates.

## Endpoint

`GET /api/v1/Subscriptions`

## Usage

```ruby
# All subscriptions (default locale es-PA)
client.subscriptions.list

# With pagination
client.subscriptions.list(page: 2, page_size: 25)

# Custom locale
client.subscriptions.list(locale: "en")
```

## Parameters

| Parameter   | Type    | Description                          |
|-------------|---------|--------------------------------------|
| `page`      | Integer | Page number (1-based)                |
| `page_size` | Integer | Results per page                     |
| `locale`    | String  | `Accept-Language` header (default `es-PA`) |

## Response

Paginated envelope:

| Field            | Type    | Description                        |
|------------------|---------|------------------------------------|
| `currentPage`    | Integer |                                    |
| `pageCount`      | Integer |                                    |
| `pageSize`       | Integer |                                    |
| `rowCount`       | Integer | Total records                      |
| `firstRowOnPage` | Integer |                                    |
| `lastRowOnPage`  | Integer |                                    |
| `data`           | Array   | Array of subscription objects      |

Each item in `data`:

| Field                    | Type    | Description                              |
|--------------------------|---------|------------------------------------------|
| `id`                     | String  | Subscription ID                          |
| `userId`                 | String  |                                          |
| `ruc`                    | String  | Taxpayer RUC                             |
| `taxpayerName`           | String  |                                          |
| `subscriptionNumber`     | String  |                                          |
| `transactions`           | Integer | Total transactions included in plan      |
| `availableTransactions`  | Integer | Remaining transactions                   |
| `status`                 | String  | e.g. `"Active"`                          |
| `validFrom`              | String  | ISO date                                 |
| `validUntil`             | String  | ISO date                                 |
| `planName`               | String  |                                          |
| `planType`               | String  |                                          |
| `partnerUserId`          | String  |                                          |
| `percentageConsumed`     | Integer | 0–100                                    |
| `unlimited`              | Boolean | `true` if plan has no transaction cap    |
| `branchOfficeCode`       | String  |                                          |
