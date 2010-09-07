if File.exist?(doc_yml = RAILS_ROOT+"/config/document.yml")
# MIME Type loading for Document Upload
  CONTENT_TYPES = YAML.load(IO.read(doc_yml))["permitted_mimes"]
# Load disallowed file extensions
  EXTENSION_TYPES = YAML.load(IO.read(doc_yml))["rejected_extensions"]
# Load ClamAV
  if YAML.load(IO.read(doc_yml))["clam_av_enable"]
    CLAM_AV = ClamAV.instance
    CLAM_AV.loaddb()
  end

else
  CONTENT_TYPES = []
  EXTENSION_TYPES = []
end
