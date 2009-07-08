class DSMLBuilder

  def self.to_dsml(entries=[])
    begin
      d=Builder::XmlMarkup.new(:target => $stdout, :indent =>2)
      d.instruct!
      ns="xmlns:dsml".to_sym
      d.dsml(:dsml, ns => "http://www.dsml.org/DSML") do |root|
        root.dsml("directory-entries".to_sym) do
          entries.each{|e| e.to_dsml(root)}
        end
      end
      
    rescue
      puts "see ya sucker"
    end
  end
end