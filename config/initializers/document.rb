if File.exist?(doc_yml = Rails.root.to_s+"/config/document.yml")
  yaml = YAML.load(IO.read(doc_yml))
  # MIME Type loading for Document Upload
  CONTENT_TYPES = yaml["permitted_mimes"]
  # Load disallowed file extensions
  EXTENSION_TYPES = yaml["rejected_extensions"]
  # Load ClamAV
  if Rails.env == 'production'
    begin
      CLAM_AV = ClamAV.instance
      CLAM_AV.loaddb()
    rescue
      CLAM_AV = nil # if it bombs out, let's move on and ignore the error.
    end
  end
else
  CONTENT_TYPES = []
  EXTENSION_TYPES = []
end
