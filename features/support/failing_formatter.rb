# features/support/twitter_formatter.rb
require 'rubygems'

module Talho
  class FailureFormatter < Cucumber::Ast::Visitor
    def initialize(step_mother, io, options)
      super(step_mother)
      @io=io
      @options = options
    end

    def visit_feature_name(name)
      name=name.split("\n").first
      @io.puts(name)
      @io.flush
    end

    def visit_step_name(keyword, step_match, status, source_indent, background)
      if status == :failed 
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        message = "#{step_name} FAILED"
        puts message
      end
    end
  end
end
