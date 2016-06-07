
# Madek - Nightly Data Deploy

This project lets us trigger deploys via Cider-CI with full data migration to
`test` and `staging-v3-pdata` via a cron-job.

## Setup

Clone this project, set the `MADEK_API_LOGIN` and `MADEK_API_PASSWORD`
variables valid for `ci.zhdk.ch`. Call the following script from the cron-job.

~~~crontab
42 21 * * * /home/cider-ci_exec-user/nightly-deploy
~~~

~~~sh
#!/usr/bin/env bash
set -eux
LOGFILE=~/nightly-deploy.log
exec > $LOGFILE 2>&1
source /etc/profile.d/rbenv-load.sh
source ~/.bash_login
rbenv-load
env > /tmp/env.output
cd /home/cider-ci_exec-user/madek_nightly-deploy-script/
bundle install
bundle exec ./deploy.rb
~~~
