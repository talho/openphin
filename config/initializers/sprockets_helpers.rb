module Sprockets
  module Helpers
    module RailsHelper
      def javascript_dominoes_paths(*sources)
        options = sources.extract_options!
        debug = options.key?(:debug) ? options.delete(:debug) : debug_assets?
        body  = options.key?(:body)  ? options.delete(:body)  : false
        digest  = options.key?(:digest)  ? options.delete(:digest)  : digest_assets?
      
        sources.collect do |source|
          if debug && asset = asset_paths.asset_for(source, 'js')
            asset.to_a.map { |dep|
              asset_path(dep, :ext => 'js', :body => true, :digest => digest)
            }
          else
            asset_path(source, :ext => 'js', :body => body, :digest => digest)
          end
        end.join(" > ").html_safe
      end

    end
  end
end