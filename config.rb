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
  WARNING = 20
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
    if repo.latest_release_date === nil
      HealthSeverity::UNKNOWN
    elsif Time.now - repo.latest_release_date > 365.days
      HealthSeverity::BAD
    else
      case repo.commits_since_last_release
      when (21..)
        HealthSeverity::BAD
      when 11..20
        if Time.now - repo.latest_release_date > 90.days
          HealthSeverity::BAD
        elsif Time.now - repo.latest_release_date > 30.days
          HealthSeverity::WARNING
        else
          HealthSeverity::GOOD
        end
      when 1..10
        if Time.now - repo.latest_release_date > 180.days
          HealthSeverity::BAD
        elsif Time.now - repo.latest_release_date > 60.days
          HealthSeverity::WARNING
        else
          HealthSeverity::GOOD
        end
      else
        HealthSeverity::GOOD
      end
    end
  end
end
