require 'jekyll-date-format'

module Jekyll

  class PostFullPath < Generator
    safe :true
    priority :high

    # Generate file info for each post and page
    #  +site+ is the site
    def generate(site)
      site.posts.each do |post|
        base = post.instance_variable_get(:@base)
        name = post.instance_variable_get(:@name)
        post.data.merge!({
          'dir_name' => '_posts',
          'file_name' => name, 
          'full_path' => File.join(base, name),
        })
      end
      site.pages.each do |page|
        base = page.instance_variable_get(:@base)
        dir = page.instance_variable_get(:@dir)
        name = page.instance_variable_get(:@name)
        page.data.merge!({
          'dir_name' => dir,
          'file_name' => name, 
          'full_path' => File.join(base, dir, name)})
      end
    end
  end

  class RevisionTag < Liquid::Tag
    DEFAULT_LIMIT = 5

    def initialize(name, marker, token)
      @params = Hash[*marker.split(/(?:: *)|(?:, *)/)]
      if @params['limit'] != nil
        /\d*/.match(@params['limit']) do |m|
          @limit = m[0].to_i
        end
      else
        @limit = DEFAULT_LIMIT
      end
      super
    end

    def render(context)
      site = context.environments.first['site']
      if site['github_user'] == nil || site['github_repo'] == nil
        puts 'Uh-oh, site is nil'
        return ''
      end

      post = context.environments.first['post']
      if post == nil
        post = context.environments.first['page']
        if post == nil
          puts 'Uh-oh, post is nil'
          return ''
        end
      end

      full_path = post['full_path']
      if full_path == nil
        puts post['title'] + ' full path is nil'
        return ''
      end

      if !File.exists?(full_path)
        puts full_path + ' does not exist'
        return ''
      end

      cmd = 'git log --date=local --pretty="%cd|%s" --max-count=' + @limit.to_s + ' ' + full_path
      logs = `#{cmd}`

      html = '<ul>'
      logs.each_line do |line|
        parts = line.split('|')
        date, msg = parts[0], parts[1..-1].join('|') # keep origin pileline from logs
        formatted_date = Jekyll::DateFormat.format_date(date, site['date_format'])
        html << '<li><strong>' + formatted_date + '</strong><br/>' + msg + '</li>'
      end
      html << '</ul>'

      dir_name = post['dir_name']
      if  dir_name == nil
        return html
      end

      cmd = 'git rev-parse --abbrev-ref HEAD'
      # chop last '\n' of branch name
      branch = `#{cmd}`.chop
      if site['source'] != nil
        # for Octopress sites
        link = File.join('https://github.com', site['github_user'], site['github_repo'],
                         'commits', branch, site['source'], post['dir_name'], post['file_name'])
      else
        # for Jekyll sites
        link = File.join('https://github.com', site['github_user'], site['github_repo'],
                         'commits', branch, post['dir_name'], post['file_name'])
      end
      html << 'View on <a href=' + link + ' target=_blank>Github</a>'

      return html
    end #render
  end # RevisionTag
end # Jekyll

Liquid::Template.register_tag('revision', Jekyll::RevisionTag)
