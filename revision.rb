require 'jekyll'
require 'jekyll/post'

module Jekyll

    class Post
        alias_method :original_to_liquid, :to_liquid

        def to_liquid
            file_name = @name
            full_path = File.join(@base, @name)
            original_to_liquid.deep_merge({
                'full_path' => full_path, 
                'file_name' => file_name
            })
        end
    end

    class RevisionTag < Liquid::Tag

        def initialize(name, marker, token)
            @params = Hash[*marker.split(/(?:: *)|(?:, *)/)]
            if @params['limit'] != nil
                /\d*/.match(@params['limit']) do |m|
                    @limit = m[0].to_i
                end
            else
                @limit = 5
            end
            super
        end

        def render(context)
            site = context.environments.first['site']
            if context.environments.first['post'] != nil
                post_or_page = context.environments.first['post']
            else
                post_or_page = context.environments.first['page']
            end

            full_path = post_or_page['full_path']

            cmd = 'git log --pretty="%H|%cd|%s" ' + full_path
            logs = `#{cmd}`
            logs = logs.to_a[0..@limit].join

            html = '<ul>'
            logs.each_line do |line|
                parts = line.split('|')
                hash = parts[0]
                date = parts[1]
                msg = parts[2]
                html << '<li><strong>' + date + '</strong><br/>' + msg + '</li>'
            end
            html << '</ul>'

            if site['github_user'] != nil && site['github_repo'] != nil 
                cmd = 'git rev-parse --abbrev-ref HEAD'
                # chop last '\n'
                branch = `#{cmd}`.chop
                if site['source'] != nil
                    source = site['source']
                else 
                    source = 'source'
                end
                link = File.join('https://github.com', site['github_user'], site['github_repo'], 
                                 'commits', branch, source, '_posts', post_or_page['file_name'])
                html << 'View in <a href=' + link + ' target=_blank>Github</a>'
            end


            return html
        end
    end
end

Liquid::Template.register_tag('revision', Jekyll::RevisionTag)
