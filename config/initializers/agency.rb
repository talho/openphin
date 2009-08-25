Agency = {
  :agency_identifier => '2.16.840.1.114222.4.3.2.2.3.770',
  :agency_domain => 'texashan.org',
  :agency_name => 'TexasHAN',
  :agency_abbreviation => 'TX',
  :phin_ms_base_path => File.expand_path(File.join(Rails.root, 'tmp', 'phin_ms_queues', Rails.env)),
  :phin_ms_path => File.expand_path(File.join(Rails.root, 'tmp', 'phin_ms_queues', Rails.env, 'CIBER_TA_PCA', 'outgoing')) 
}