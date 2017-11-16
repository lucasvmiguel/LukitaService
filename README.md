# LukitaService
[![Build Status](https://travis-ci.org/lucasvmiguel/lukita_service.svg?branch=master)](https://travis-ci.org/lucasvmiguel/lukita_service)

This project is a simple lib to organize your ruby project.

## Install

In your Gemfile:
```ruby
gem 'lukita_service'
```

## Getting start

Implement your service class like this

```ruby
require 'lukita_service'

class SumService < LukitaService::Base
  def execute(params)
    num1 = params[:a]
    num2 = params[:b]

    if num1 != nil && num2 != nil
      {valid?: true, result: {sum: num1 + num2}}
    else
      {valid?: false}
    end
  end
end
```
and use like this

**Attention**: in pipe the result of service before will be appended in params of the next service

```ruby
SumService.run(a: 1, b: 2)

#or

LukitaService
  .pipe(SumService, {a: 1, b: 2})
  .pipe(SumService) # WHEN EXECUTE THIS SUMSERVICE WILL RECEIVE :sum as parameter
  .pipe(LogService) # DOES NOT EXECUTE, BECAUSE SUMSERVICE WILL BE INVALID
  .done
```

## Documentation

[here](http://www.rubydoc.info/gems/lukita_service)

## License

[MIT](LICENSE)