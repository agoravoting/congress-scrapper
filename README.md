# Congress Scrapper

## Introduction

Congress Scrapper is a Ruby gem to scrape the official Spanish parliament webpage.

## Usage

```ruby
  proposals = Congress::Scrapper.scrape # Array with Congress proposals
  proposal = proposals.first
  
  puts proposal.proposal_type
  >> "Proyecto de Ley"
  
  puts proposal.title
  >> "Proyecto de Ley de almacenamiento geológico de dióxido de carbono"
```

## Install

<pre>
  gem install congress-scrapper
</pre>

## Contribute

1. Find or create an issue
    
2. Add a comment to the issue to let people know you're going to work on it
    
3. Fork
    
4. Hack your changes in a topic branch (don't forget to write some tests ;)
    
5. Make pull request
    
6. Wait for comments from maintainers or code merge


## Authors

Original author: Luismi Cavallé

Code extracted as a ruby gem by: Raimond García and Alberto Fernández-Capel


## License

Released under the MIT license.