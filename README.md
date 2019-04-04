# README

### Dependencies
- ruby
- node
- postgresql

# INSTALL

`bundle install`

`bundle exec rake db:create db:migrate`

`rails s`

### Getting a package list

`bundle exec rake refresh[organisation-name]`

Ensure to specify an environment variable with your gihub token, otherwise you will only get the public repositories, not the private ones

`export GITHUB_ACCESS_TOKEN=<your token>`

### Using the app

Navigate to http://locahost:3000 and type in the name of the gem in the search field
