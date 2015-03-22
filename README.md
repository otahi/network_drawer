# NetworkDrawer

A network diagram drawer with json or yaml.

[![Gem Version](https://badge.fury.io/rb/network_drawer.svg)](http://badge.fury.io/rb/network_drawer)

## Installation

Ensure you can use [Graphviz](http://www.graphviz.org/), before installing network_drawer.

You can install Graphviz as follow.
```
# Mac OS X with brew
brew install graphviz

# CentOS
yum install graphviz

# Ubuntu
apt-get install graphviz
```

Add this line to your application's Gemfile:

```ruby
gem 'network_drawer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install network_drawer

## Usage

You can draw a network diagram with a JSON or YAML file with SVG format:

    $ bundle exec network_drawer draw examples/simple.json

    $ bundle exec network_drawer draw examples/simple.yml

You can draw a network diagram with specified style:

    $ bundle exec network_drawer draw examples/simple.json -s examples/simple_style.json

    $ bundle exec network_drawer draw examples/simple.yml -s examples/simple_style.yml

You can draw a network diagram with specified layout(dot, fdp..):

    $ bundle exec network_drawer draw examples/simple.json -l fdp

You can draw a network diagram with png format:

    $ bundle exec network_drawer draw examples/simple.json -f png

Then You will get a network diagram.

[sample diagram(SVG)](examples/simple.svg)

![sample diagram(PNG)](examples/simple.png)

## How to describe

You can describe diagram with JSON.

### Network diagram

You can describe diagram as follows:

[simple.yml](examples/simple.yml)
```yaml
layers:
- Web:
    nodes:
    - WebLB:
        ports:
        - 80/tcp
        - 443/tcp
        type: LB
        url: https://github.com/otahi/network_drawer/
    - Web001:
        ports:
        - 80/tcp
    - Web002:
        ports:
        - 80/tcp
- App:
    nodes:
    - AppLB:
        ports:
        - 80/tcp
        - 25/tcp
        type: LB
    - App001:
        ports:
        - 80/tcp
        - 25/tcp
    - App002:
        ports:
        - 80/tcp
        - 25/tcp
nodes:
- Browser:
  type: Client
- Mail Server:
  type: Client
connections:
- from: Browser
  to: WebLB:80/tcp
  type: HTTP
- from: Browser
  to: WebLB:443/tcp
- from: Mail Server
  to: AppLB:25/tcp
  type: SMTP
- from: WebLB
  to: Web001:80/tcp
  type: HTTP
- from: WebLB
  to: Web002:80/tcp
  type: HTTP
- from: Web001
  to: AppLB:80/tcp
  type: HTTP
- from: Web002
  to: AppLB:80/tcp
  type: HTTP
- from: AppLB
  to: App001:25/tcp
  type: SMTP
- from: AppLB
  to: App001:80/tcp
  type: HTTP
- from: AppLB
  to: App002:25/tcp
  type: SMTP
- from: AppLB
  to: App002:80/tcp
  type: HTTP
```

### Style

You can specify your style for nodes or edges with [Graphviz attributes](http://www.graphviz.org/content/attrs).

[simple_style.yml](examples/simple_style.yml)
```yaml
types: 
  WEB: 
    style: rounded,filled,dotted
    fillcolor: azure
  LB: 
    style: rounded,filled,dotted
    fillcolor: azure
  HTTP: 
    color: blue
  SMTP: 
    color: green
```

## Contributing

1. Fork it ( https://github.com/otahi/network_drawer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
