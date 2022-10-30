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
  UNKNOWN = 5
  GOOD = 10
  WARNING = 20
  BAD = 30

  COLOR = {
    UNKNOWN => "mdl-color--grey",
    GOOD => "mdl-color--green",
    WARNING => "mdl-color--amber",
    BAD => "mdl-color--red",
  }

end

# Temporary monkey-patch to force use of unsafe YAML load with Ruby 3.1. This is required because  Middleman 4.4.2's
# Middleman::Util::Data does not currently define necessary permitted_classes to allow releases_dashboard.yaml to load
# as https://github.com/middleman/middleman/commit/f9f92dd52b11f922c055e1e6c352e0f997bcc7e4#diff-53e56e0b3ba9fbec173135ae691c6892a94ef9838534e4662c9d983f1214f97f
# has not been released. Easiest way here is to fall back to Ruby 2.7.x behaviour (Psych 3.3.x) and unsafe load.
module ::YAML
  class << self
    alias_method :load, :unsafe_load
  end
end


helpers do
  def color_for(repo)
    HealthSeverity::COLOR[severity_for(repo) || (raise "unknown severity for repo #{repo}")]
  end

  def severity_for(repo)
    if repo.latest_release_date === nil
      HealthSeverity::UNKNOWN
    elsif Time.now - repo.latest_release_date > 180.days && repo.latest_release_download_per_month.round <= 1
      # If it's been a while since latest release, and basically no-one downloads, do we care?
      HealthSeverity::UNKNOWN
    elsif Time.now - repo.latest_release_date > 365.days
      HealthSeverity::BAD
    else
      case repo.commits_since_last_release
      when (41..)
        HealthSeverity::BAD
      when 21..40
        if Time.now - repo.latest_release_date > 180.days
          HealthSeverity::BAD
        elsif Time.now - repo.latest_release_date > 60.days
          HealthSeverity::WARNING
        else
          HealthSeverity::GOOD
        end
      when 1..20
        if Time.now - repo.latest_release_date > 270.days
          HealthSeverity::BAD
        elsif Time.now - repo.latest_release_date > 120.days
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
