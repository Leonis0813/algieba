# algieba

**algieba provides Web API for account management**

## Requirements

- Ruby 2.2.0
- bundler(gem)
- RVM
- MySQL
- web server software like Apache, Nginx

## APIs

|HTTP Method|Path           |Description    |
|:----------|:--------------|:--------------|
|POST       |/payments      |create payment |
|GET        |/payments/[:id]|read payment   |
|GET        |/payments      |search payments|
|PUT        |/payments/[:id]|update payment |
|DELETE     |/payments/[:id]|delete payment |
|GET        |/settlement    |settle up      |

## Deployment

- Use https://github.com/Leonis0813/subra

```
git clone https://github.com/Leonis0813/subra.git
cd subra
./install_chef.sh <your centos version>
sudo chef-client -z -r algieba -E production
```

## Development

- Usage

```
git clone https://github.com/Leonis0813/algieba.git
cd algieba
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
```
