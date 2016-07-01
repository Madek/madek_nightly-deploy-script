
# Madek - Nightly Data Deploy

This project lets us trigger deploys via Cider-CI with full data migration to
`test` and `staging-v3-pdata` via a cron-job.

## Setup

Clone this project, set the `MADEK_API_LOGIN` and `MADEK_API_PASSWORD`
variables valid for `ci.zhdk.ch`. Call the following script from the cron-job.

~~~crontab
42 21 * * * /home/madek-ci-api-user/nightly-deploy
~~~

~~~sh
#!/usr/bin/env bash
set -eux
LOGFILE=~/nightly-deploy.log
exec > $LOGFILE 2>&1
export PATH=${HOME}/.rubies/ruby-2.2.5/bin:$PATH
env > /tmp/env.output
gem install bundler
cd ${HOME}/madek_nightly-deploy-script/
bundle install
bundle exec ./deploy.rb
~~~
