## Show Post's Revision History For Jekyll/Octopress Powered Sites
This plugin provide a Liquid tag to generate blog post's revision history, which
are merely commit messages when you do `git commit`. See a demo on [this
site](http://jhshi.me).

### Installation
Put `revision.rb` to your `/_plugins/` (for Jekyll) or `/plugins/` (for
Octopress) directory of your blog source root.

### Configuration
If your blog source are hosted on Github, you can set two optional
configurations in your `_config.yml`. Then this plugin will also generate links
to Github commit history for each post.

- `github_user`: your user name on Github
- `github_repo`: your blog source repo name on Github. More specifically, for Jekyll sites
  hosted on Github Pages, this should be `SOMEBODY.github.[io][com]`.


### Usage
Put `revision.html` somewhere in your `_include` (for Jekyll) or
`source/_include` (for Octopress) directory. And include this html file
somewhere in your post layout file.

One optional argument, `limit`, is accepted by the `revision` tag. It specifies
the maximum `git-log` number. It's default value is 5.


### Notes

When generate Github commit history links, this plugin assumes that:

- If you specify `source` in your `_config.yml`, then blog posts are in
  `source/_posts` directory. (For Octopress sites)

- Otherwise, blog posts should be in `_posts` directory. (For Jekyll sites)

If this assumption is not right in your case, then you'll probably need to tweak
the url patterns a little bit.
