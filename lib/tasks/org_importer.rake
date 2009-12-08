begin
  desc 'Organization importer task -- call as rake org_importer file=<filename_and_path>'
  task :orgs_import => :environment do
    OrgImporter.import_orgs ENV['file']
  end

  desc 'Organization importer task -- call as rake dshs_data_migrate file=<filename_and_path>'
  task :ddm => "orgs_import"
end