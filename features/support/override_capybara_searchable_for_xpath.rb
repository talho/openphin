# Fix for capybara regex bug that was causing the regex expression to be re-escaped multiple times until the system overloaded.
# This should be removed when Capybara has moved beyond version 0.3.9 as it has been fixed in the codebase after that version
# came out.

module Capybara
  module Searchable
    def all(* args)
      options = if args.last.is_a?(Hash) then args.pop else {} end
      if args[1].nil?
        kind, locator = Capybara.default_selector, args.first
      else
        kind, locator = args
      end
      locator = XPath.from_css(locator) if kind == :css

      results = all_unfiltered(locator)

      if options[:text]

        if options[:text].kind_of?(Regexp)
          regexp = options[:text]
        else
          regexp = Regexp.escape(options[:text])
        end

        results = results.select { |n| n.text.match(regexp) }
      end

      if options[:visible] or Capybara.ignore_hidden_elements
        results = results.select { |n| n.visible? }
      end

      results
    end
  end
end