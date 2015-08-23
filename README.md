# algieba

**application for account management**

## Directory Structure

    CHANGELOG.md
    Gemfile
    README.md
    Rakefile
    app    -- assets       -- images
              	           -- javascripts  -- ...
           	           -- stylesheets  -- ...
           -- controllers  -- accounts_controller.rb
                           -- ...
           -- concerns
           -- helpers      -- accounts_helper.rb
                           -- ...
           -- mailers
           -- models       -- account.rb
                           -- concerns
           -- views        -- accounts
                           -- layouts -- ...
    bin    -- ...
    config -- environments -- ...
           -- initializers -- ...
           -- locales      -- ...
           -- ...
    config.ru
    db     -- migrate      -- ...
           -- ...
    lib    -- ...
    log    -- ...
    public -- ...
    test   -- controllers  -- accounts_controller_test.rb
           -- fixtures     -- accounts.yml
           -- models       -- account_test.rb
           -- ...
    tmp    -- cache        -- assets
           -- pids         -- server.pid
           -- sessions
           -- sockets
    vendor -- assets       -- ...

## API

|HTTP Method|Path        |Description     |Parameters                               |
|:----------|:-----------|:---------------|:----------------------------------------|
|GET        |/accounts   |search accounts |conditions for select                    |
|POST       |/accounts   |regist account  |account infomations                      |
|PUT        |/accounts   |update accounts |conditions and values for update         |
|DELETE     |/accounts   |delete accounts |conditions for delete                    |
|GET        |/settlement |settle up       |period("yearly" or "monthly" or "daily") |

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
