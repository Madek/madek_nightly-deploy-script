#!/usr/bin/env ruby

require 'active_support/all'
require 'json_roa/client'
require 'pry'

API_BASE_URL = ENV['MADEK_API_BASE_URL'].presence || 'https://ci.zhdk.ch/cider-ci/api'
# API_BASE_URL = 'http://localhost:8888/cider-ci/api'


@client = JSON_ROA::Client.connect API_BASE_URL do |conn|
  conn.basic_auth(ENV['MADEK_API_LOGIN'].presence,
                  ENV['MADEK_API_PASSWORD'].presence)
  conn.ssl.verify = false
end

def get_tree_id(repository_url, name_branch_head)
  @client.get.relation(:commits) \
    .get(repository_url: repository_url,
         branch_head: name_branch_head) \
    .collection.first.get.data[:tree_id]
end

def get_job_id(tree_id, key)
  job_rel = @client.get.relation(:jobs).get(tree_id: tree_id, key: key) \
            .collection.first
  job_rel && job_rel.get.data[:id]
end

def retry_first_task(job)
  job.relation(:tasks).get.collection.first.get \
    .relation(:trials).get.relation(:retry).post
end

def create_job(tree_id, key)
  @client.get.relation(:create_job) \
    .post({},
          { tree_id: tree_id, key: key }.to_json,
          content_type: 'application/json')
end

def create_job_or_retry(tree_id, key)
  if (job_id = get_job_id(tree_id, key))
    retry_first_task(@client.get.relation(:job).get(id: job_id))
    job_id
  else
    create_job(tree_id, key).data[:id]
  end
end

def wait_for_passed(job_id, started_at = Time.now)
  if Time.now - started_at > 3.hours
    fail 'Timeout!'
  else
    state = @client.get.relation(:job).get(id: job_id).data[:state]
    case state
    when 'passed'
      puts 'Yay'
    when 'pending', 'executing'
      sleep(60)
      wait_for_passed job_id, started_at
    when 'failed', 'aborted', 'aborting'
      fail 'FAILED'
    else
      fail 'UKNOWN STATE'
    end
  end
end

tree_id = get_tree_id('https://github.com/Madek/madek.git', 'master')

['deploy_test_with-restore-data',
 'deploy_staging-v3-pdata_with-restore-data'].each do |job_key|
  job_id = create_job_or_retry tree_id, job_key
  wait_for_passed job_id
end

puts 'DONE!'
exit 0
