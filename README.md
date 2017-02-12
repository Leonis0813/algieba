# algieba

**algieba provides Web API for account management**

## APIs

|HTTP Method|Path           |Description    |
|:----------|:--------------|:--------------|
|POST       |/payments      |create payment |
|GET        |/payments/[:id]|read payment   |
|GET        |/payments      |search payments|
|PUT        |/payments/[:id]|update payment |
|DELETE     |/payments/[:id]|delete payment |
|GET        |/settlement    |settle up      |

### Examples

#### GET /accounts

    URL: http://localhost/accounts?account_type=income

#### POST /accounts

    URL: http://localhost/accounts
    JSON Body: {
        "account": {
            "account_type": <"income" or "expense">,
            "date": "yyyy-mm-dd",
            "content": <content>,
            "category": <category>,
            "price": <price>
        }
    }

#### PUT /accounts

    URL: http://localhost/accounts
    JSON Body: {
        "condition": {
            "account_type": <"income" or "expense">,
            "category": <category>
        },
        "with": {
            "category": <category>
        }
    }

#### DELETE /accounts

    URL: http://localhost/accounts
    JSON Body: {
    	"date": "yyyy-mm-dd",
        "content": <content>
    }

#### GET /settlement

    URL: http://localhost/settlement?period=monthly

## DB

- Account table

|Column Name  |Type    |Description                            |
|:------------|:-------|:--------------------------------------|
|account_type |varchar |descript "income" or "expense"         |
|date         |date    |date which has a income or expense     |
|content      |varchar |description of the account             |
|category     |varchar |tags to classify accounts              |
|price        |integer |amount of income or expense            |
