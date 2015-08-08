# algieba

**application for account management**

## Directory Structure

    CHANGELOG.md
    Gemfile
    Gemfile.lock
    README.md
    Rakefile
    app    -- assets
           -- images
           -- javascripts  -- ...
           -- stylesheets  -- ...
           -- controllers  -- accounts_controller.rb
                           -- application_controller.rb
           -- concerns
           -- helpers      -- accounts_helper.rb
                           -- application_helper.rb
           -- mailers
           -- models       -- account.rb
                           -- concerns
           -- views        -- accounts
                           -- layouts -- application.html.erb
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

|HTTP Method|Path        |Description     |Parameters                         |
|:----------|:-----------|:---------------|:----------------------------------|
|GET        |/accounts   |search accounts |conditions for select              |
|POST       |/accounts   |regist account  |account infomations                |
|PUT        |/accounts   |update accounts |conditions and values for update   |
|DELETE     |/accounts   |delete accounts |conditions for delete              |
|GET        |/settlement |settle up       |period(yearly or monthly or daily) |

## DB

- Account table

|Column Name  |Type    |Description                            |
|:------------|:-------|:--------------------------------------|
|account_type |varchar |descript "income" or "expense"         |
|date         |date    |date which has a income or expense     |
|content      |varchar |description of the account             |
|category     |varchar |tags to classify accounts              |
|price        |integer |amount of income or expense            |
