require 'configuration'
CONFIG = Configuration.load! do
  option_string 'rp_display_locales', 'RP_DISPLAY_LOCALES'
  option_string 'idp_display_locales', 'IDP_DISPLAY_LOCALES'
  option_string 'session_cookie_duration', 'SESSION_COOKIE_DURATION_IN_HOURS', default: 2
  option_string 'api_host', 'API_HOST'
  option_string 'logo_directory', 'LOGO_DIRECTORY'
  option_string 'white_logo_directory', 'WHITE_LOGO_DIRECTORY'
  option_string 'zdd_file', 'ZDD_LATCH'
  option_string 'polling_wait_time', 'POLLING_WAIT_TIME', default: 6
  option_bool 'metrics_enabled', 'METRICS_ENABLED', default: true
  if metrics_enabled
    option_string 'statsd_host', 'STATSD_HOST', default: '127.0.0.1'
    option_string 'statsd_port', 'STATSD_PORT', default: 8125
    option_string 'statsd_prefix', 'STATSD_PREFIX'
  end
  option_string 'internal_piwik_host', 'INTERNAL_PIWIK_HOST', allow_missing: true
  option_string 'public_piwik_host', 'PUBLIC_PIWIK_HOST', allow_missing: true
  option_int 'piwik_site_id', 'PIWIK_SITE_ID', default: 1
  option_int 'read_timeout', 'READ_TIMEOUT', default: 60
  option_int 'connect_timeout', 'CONNECT_TIMEOUT', default: 4
  option_string 'rules_directory', 'RULES_DIRECTORY'
end
