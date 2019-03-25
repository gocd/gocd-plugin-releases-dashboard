require 'active_support/core_ext/numeric/time'
activate :relative_assets
set :relative_links, true

activate :livereload, apply_js_live: false, apply_css_live: true, no_swf: true

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

configure :build do
  activate :minify_css
  activate :minify_javascript
end

class HealthSeverity
  GOOD = 10
  WARNING = 30
  BAD = 30
  UNKNOWN = 40

  COLOR = {
    UNKNOWN => "mdl-color--grey",
    GOOD => "mdl-color--green",
    WARNING => "mdl-color--amber",
    BAD => "mdl-color--red",
  }

end


helpers do
  def color_for(repo)
    HealthSeverity::COLOR[severity_for(repo) || (raise "unknown severity for repo #{repo}")]
  end

  def severity_for(repo)
    case repo.commits_since_last_release
    when nil
      HealthSeverity::UNKNOWN
    when 0
      HealthSeverity::GOOD
    when 1..2
      if Time.now - repo.latest_release_date < 3.days
        HealthSeverity::GOOD
      elsif Time.now - repo.latest_release_date < 7.days
        HealthSeverity::WARNING
      else
        30
      end
    when 3..5
      HealthSeverity::WARNING
    else
      HealthSeverity::BAD
    end
  end
end
