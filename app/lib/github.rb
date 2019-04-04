require 'octokit'

class Github
  def self.refresh(org)
    GemAudit.update

    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

    print '*' * 20
    print 'limit'
    puts '*' * 20
    puts client.rate_limit
    puts '*' * 20

    client.auto_paginate = true

    projects = []

    client.org_repos(org).each do |repo|
      print '.'
      next if repo.archived?
      begin
        lockfile = client.contents(repo.full_name, path: 'Gemfile.lock')
        projects << RubyProject.new(repo.full_name, lockfile)
      rescue Octokit::NotFound => _e
      end
    end

    puts ''

    Package.destroy_all
    Project.destroy_all

    vulns = []

    projects.each do |project|
      p = Project.create!(
        name: project.name,
        ruby_version: project.version,
        lockfile: project.contents
      )

      print '*' * 10
      print 'audit'
      puts '*' * 10

      vulns << project.audit

      puts '*' * 10

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

    print '*' * 20
    print 'limit'
    puts '*' * 20
    puts client.rate_limit
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
