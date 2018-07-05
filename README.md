# Sauron [![Build Status](https://travis-ci.org/alexis-lxc/sauron.svg?branch=master)](https://travis-ci.org/alexis-lxc/sauron)

NOTE: Not ready for Production use.

## Purpose 

Sauron is a Rails app to enable its users to leverage the power of LXD. 
You can add all the LXD Nodes of a cluster, on which you can add, view and delete containers. 

As of now, only `ubuntu:16.04` image containers are spawned


## How to setup locally(on macOSX)

Ensure that Redis and Postgres are up and running before running the following commands:

* Copy file `application.yml.sample` to `application.yml`
* Run `gem install bundler` 
* Run `bundle install` to install the gems
* Run `bundle exec rake db:create` to create the DB
* Run `bundle exec rake db:migrate` to run migrations
* Run `bundle exec rails server` to start the server on default port
* On another terminal session `bundle exec sidekiq` to start sidekiq

## You need following installed:

```
* ruby version 2.5.1
* Redis
* Postgres
```

### How to run unit tests

*  ```gem install bundler```
* ```bundle install```
* ```bundler exec rspec```

## How to contribute:

* Create an issue;
* Have discussion;
* Raise a PR 

## Maintainers:

* [Akashdeep Singh](https://github.com/akashkahlon)
* [Sahil Kharb](https://github.com/bitfury)
* [Kumaran Venkataraman](https://github.com/kumaranvram)
