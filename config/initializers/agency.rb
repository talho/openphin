Agency = {
  :agency_identifier => '2.16.840.1.114222.4.1.3683',
  :agency_domain => 'dshs.state.tx.us',
  :agency_name => 'Texas Department of State Health Services',
  :agency_abbreviation => 'DSHS',
  :phin_ms_base_path => File.expand_path(File.join(Rails.root, 'tmp', 'phin_ms_queues', Rails.env)),
  :phin_ms_path => File.expand_path(File.join(Rails.root, 'tmp', 'phin_ms_queues', Rails.env, 'receiverincoming')) 
}