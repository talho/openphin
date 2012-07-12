begin # if airbrake exists, configure it. This is only going to exist in production mode, though.
  Airbrake.configure do |config|
    config.api_key = 'c2d88a8d0e1d5e525b5d17f5b6cf7f1c'
  end
rescue
end