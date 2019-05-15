require 'octokit'

class Github

  def self.print_limit(client)
    print '*' * 10
    print '  limit  '
    print client.rate_limit.remaining
    print '  '
    puts '*' * 10
  end

  def self.each_repo(org)
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    client.auto_paginate = true

    print_limit(client)

    client.org_repos(org).each do |repo|
      print '.'
      yield repo, client
    end

    puts ''

    print_limit(client)

    puts ''
  end

  class RepoStats
    def initialize(client, repo)
      @repo = repo
      @client = client
    end

    def write(filename)
      File.open(filename, 'a') do |f|
        total_lines = lines_of_code
        changes_per_week&.each do |c|
          f.write("#{@repo.full_name}, #{total_lines}, #{c.join(',')}\n")
        end
      end
    end

    private

    def lines_of_code
      @client.languages(@repo.full_name).to_h.values.sum
    end

    def changes_per_week
      @client.code_frequency_stats(@repo.full_name)
    end
  end

  def self.refresh(org)
    GemAudit.update

    projects = []
    File.open('githubstats.csv', 'w') do |f|
      f.write("repo,total_lines,week,additions,deletions\n")
    end

    each_repo(org) do |repo, client|
      next if repo.archived?
      begin
        stats = RepoStats.new(client, repo)
        stats.write('githubstats.csv')

        lockfile = client.contents(repo.full_name, path: 'Gemfile.lock')
        projects << RubyProject.new(repo.full_name, lockfile)
      rescue Octokit::NotFound => _e
      end
    end

    Package.destroy_all
    Project.destroy_all

    vulns = []

    projects.each do |project|
      p = Project.create!(
        name: project.name,
        ruby_version: project.version,
        lockfile: project.contents
      )

      vulns << project.audit

      project.gems.each do |g|
        Package.create!(
          name: g.name,
          version: g.version,
          project: p,
          project_name: p.project_name,
          organisation_name: p.organisation_name,
          ruby_version: p.ruby_version
        )
      end
    end

    puts "Vulnerabilities"
    puts '*' * 20
    puts vulns.inspect
  end

  class RubyProject
    attr_reader :name, :contents

    def initialize(name, lockfile)
      @name = name
      @contents = Base64.decode64(lockfile.content)
    end

    def gems
      parsed_content.specs.map do |spec|
        RubyGem.new(spec.name, spec.version, @name)
      end
    end

    def audit
      GemAudit.scan(@contents)
    end

    def version
      parsed_content.ruby_version
    end

    private

    def parsed_content
      @parsed_content ||= Bundler::LockfileParser.new(@contents)
    end
  end

  class RubyGem
    attr_reader :name, :version, :porject_name

    def initialize(name, version, project_name)
      @name = name
      @version = version
      @project_name = project_name
    end
  end
end
