require 'octokit'

class Github
  def self.refresh
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    client.auto_paginate = true

    projects = []

    client.org_repos('prodigyfinance').each do |repo|
      begin
        lockfile = client.contents(repo.full_name, path: 'Gemfile.lock')
        dotruby = client.contents(repo.full_name, path: '.ruby-version')

        projects << RubyProject.new(repo.full_name, lockfile, dotruby)
      rescue Octokit::NotFound => _e
        puts "#{repo.full_name} does not have a Gemfile.lock file"
      end
    end

    Package.destroy_all
    Project.destroy_all

    projects.each do |project|
      p = Project.create!(
        name: project.name,
        language: 'ruby',
        language_version: project.version
      )

      project.gems.each do |g|
        Package.create!(
          name: g.name,
          version: g.version,
          project: p,
          project_name: p.project_name,
          organisation_name: p.organisation_name,
          language_version: p.language_version
        )
      end
    end
  end

  class RubyProject
    attr_reader :name

    def initialize(name, lockfile, dotruby)
      @name = name
      @contents = Base64.decode64(lockfile.content)
      @dotruby = Base64.decode64(dotruby.content)
    end

    def gems
      parsed_content.specs.map do |spec|
        RubyGem.new(spec.name, spec.version, @name)
      end
    end

    def version
      parsed_content.ruby_version || @dotruby
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
