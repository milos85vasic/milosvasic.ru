# Single source of truth for the website version: the committed VERSION file.
# Exposes site.mv_version (semver) and site.mv_release_url_prefix to every
# layout; _layouts/default.html renders the footer link from them. Fails the
# build on a missing or non-semver VERSION rather than shipping a wrong footer.
require "jekyll"

Jekyll::Hooks.register :site, :after_init do |site|
  path = File.join(site.source, "VERSION")
  raise Jekyll::Errors::FatalException, "VERSION file missing: #{path}" unless File.file?(path)
  v = File.read(path).strip
  unless v =~ /\A\d+\.\d+\.\d+\z/
    raise Jekyll::Errors::FatalException, "VERSION must be semver MAJOR.MINOR.PATCH, got #{v.inspect}"
  end
  site.config["mv_version"] = v
  site.config["mv_release_url_prefix"] = "https://github.com/milos85vasic/milosvasic.ru/releases/tag/v"
end
