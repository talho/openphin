# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.

is_secure = Rails.env == "production" || ENV["HTTPS"] == "true"

ActionController::Base.session = {
  :key         => '_openphin_session',
  :secret      => '9ed7472b6822303797320ba8b546bc484c0bc250b4fadecfbed06165a633f44fdefb2026180f79a411bbe29e2980c0544e0b442aa3a717d283b34d05dd6fe3d2',
  :secure      => is_secure
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
