begin
  desc 'DSHS Data Migration task -- call as rake dshs_data_migrate file=<filename_and_path>'
  task :dshs_data_migrate => :environment do
    DshsDataImporter.userImport ENV['file']
  end

  desc 'DSHS Data Migration task -- call as rake dshs_data_migrate file=<filename_and_path>'
  task :ddm => "dshs_data_migrate"
end