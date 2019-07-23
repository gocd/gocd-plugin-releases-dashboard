require 'bundler/setup'
Bundler.require(:default)

desc "clean everything"
task :clean do
  rm_rf "data/gen"
end

desc "Prepare the database"
task :prepare => [:clean] do
  mkdir_p ["data/gen", "data/gen/plugins"]
  client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'], auto_paginate: true)

  release_repos = []

  ['gocd', 'gocd-contrib'].each do |each_org|
    all_repos = client.organization_repositories(each_org)
    all_repos.each do |each_repo|
      next if each_repo.archived?
      repo_full_name = each_repo.full_name
      repo_description = each_repo.description

      next if repo_full_name =~ /skeleton/
      next if repo_full_name =~ /sample-plugin/
      next if repo_full_name =~ /example/
      next if repo_full_name =~ /test-external/
      next if repo_full_name =~ /plugin-api\.go/
      next if repo_full_name =~ /go-plugins/
      next if repo_full_name =~ /gocd-plugin-releases-dashboard/
      next if repo_full_name =~ /gocd-plugin-gradle-task-helpers/
      next if repo_full_name =~ /gocd-package-material-plugin-shim/
      next if repo_full_name =~ /plugin-build-and-deploy-config-repo/
      next if repo_full_name =~ /gocd-plugin-info/

      if repo_full_name =~ /plugin/ || repo_description =~ /plugin/
        release_repos << repo_full_name
      end
    end
  end

  release_stats = release_repos.collect do |each_repo|
    begin
      latest_release = client.latest_release(each_repo)
      git_sha_for_release = latest_release.target_commitish
      compare = client.compare(each_repo, git_sha_for_release, 'master')
      commits_since_last_release = compare.total_commits

      {
        repo_name: each_repo,
        latest_release_name: latest_release.name,
        latest_release_date: latest_release.created_at,
        tag_name: latest_release.tag_name,
        git_sha_for_release: git_sha_for_release,
        compare_url: compare.html_url,
        latest_release_url: latest_release.html_url,
        commits_since_last_release: commits_since_last_release
      }
    rescue => e
      {
        repo_name: each_repo
      }
    end
  end

  open("data/gen/releases_dashboard.yaml", 'w') do |f|
    f.write(release_stats.to_yaml)
  end
end


task :build => :prepare
