

    #!/usr/bin/env bash
    set -eux
    logfile=~/nightly-deploy_$$.log
    exec > $logfile 2>&1
    source /etc/profile.d/rbenv-load.sh
    source ~/.bash_login
    env > /tmp/env.output
    cd /home/cider-ci_exec-user/madek_nightly-deploy-script/
    bundle install
    bundle exec ./deploy.rb
