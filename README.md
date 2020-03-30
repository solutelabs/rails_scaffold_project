
# Rails base Scaffold Project

## Basic setup includes

### Ruby and Rails
Ruby Version: 2.6.5
Rails Version: 6.0.2

### Postgresql (pg)
Gem pg is already installed and configured. [Click here]([https://www.postgresql.org/download/](https://www.postgresql.org/download/)) to install postgresql. Add postgresql username and password to database.yml config file and run the following command.

`rake db:create db:migrate db:seed`

### Graphql and JWT
For APIs, Graphql and JWT is configured. With graphql, `graphql-errors` is also configured to handle errors.

### Action policy and Action policy graphql
To have role based access to application; action-policy and action-policy-graphql is configured. Define policies in `app/policies` folder as per requirements. 

### Sentry: custom logger
To log the server errors for staging and production environment; sentry is configured. Get sentry dns credentials; [click here]([https://sentry.io/](https://sentry.io/)). Now, edit `credentials.yml` with using `master.key` to add `sentry_dsn` key to each `staging` and `production` environment.  


### Mina
Mina is already configured for deployment of application to Production, Staging, etc. environments. Add server and repository configuration to `staging.rb` and `production.rb` resides in `config/deploy` directory.  After this, you are all set to deploy app with `mina YOUR_ENV deploy` command.

### Rubocop
Robocop used for code quality management. Update rubocop configuration in `.rubocop.yml` if required.

### Sidekiq
Sidekiq used to have background job in application.

### Localization
Localization comes with rails by default.

### Testing
To test application RSpec is configured with FactoryBot and Shoulda-Matcher.
