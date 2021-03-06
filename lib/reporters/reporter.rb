module Reporters
  class Reporter < Struct.new(:params)
  
    class Logger  # default dummy logger
      def info(t) end
      def fatal(t) end
    end
  
    def perform
      report_id = params[:report_id]
      logger = REPORT_LOGGER || Logger.new
      begin
        begin
          report = Report::Report.find_by_id(report_id)
          logger.info %Q(Report "#{report.name}" started.)
        rescue
          message = "Reporter could not find report with report_id of #{report_id}"
          raise StandardError, message
        end
        if ( author = report.author )
          logger.info %Q(Report "#{report.name}", Author is #{report.author.display_name})
        else
          message = %Q(Report "#{report.name}" could not find author with id of #{report[:author_id]})
          raise StandardError, message
        end
        begin
          recipe = report.recipe.constantize
          logger.info %Q(Report "#{report.name}", recipe is "#{recipe.name})
        rescue
          message = %Q(Report "#{report.name}" could not find #{report.recipe})
          raise StandardError, message
        end
  
        begin
          view = view_for_at_using author, recipe
        rescue StandardError => e
          message = %Q{report "#{report.name}" erred in building supporting view: (#{e})}
          full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
          fatal_logging(logger,report,full_message)
        end
  
        unless params[:filters] || params[:render_only]
  
          begin
            start_time = Time.now
              recipe.capture_to_db report
            logger.info %Q{Report "#{report.name}", Data Capture #{Time.now-start_time} seconds}
          rescue StandardError => e
            message = %Q{Report "#{report_id}" erred in capturing data: (#{e})}
            full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
            fatal_logging(logger,report,full_message)
          end
  
        end

        begin
          start_time = Time.now
          template_path = recipe.template_path
          unless Pathname(template_path).absolute?
            template_path = File.join(view.view_paths.first,recipe.template_path)
          end
          recipe.generate_rendering report, view, template_path, params[:filters]
          logger.info %Q{Report "#{report.name}", Rendering HTML #{Time.now-start_time} seconds}
          ReportMailer.report_generated(report.author.email,report.name).deliver
        rescue StandardError => e
          message = %Q{Report "#{report.name}" erred in rendering html: (#{e})}
          full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
          fatal_logging(logger,report,full_message)
        end
  
      rescue StandardError => e
        fatal_logging(logger,report,e.message)
      end
  
    end
  
  protected
  
    def view_for_at_using(owner,recipe)
      path = Rails.configuration.paths["app/views"].first     # default path
      view = ActionView::Base.new path
      view.view_paths << File.dirname(recipe.template_path)   # path for partial resolver
      view.class_eval do
      # current_user support for any subsequent capture query logic
        define_method :current_user do
          User.find_by_id owner[:id]
        end
        include ApplicationHelper
        helpers = recipe.respond_to?(:helpers) ? (recipe.helpers || []) : []
        helpers.each {|h| include h.constantize}
      end
      view
    end
  
    def time_now
      Time.now.to_formatted_s(:db)
    end
  
    def fatal_logging(logger,report,message)
      logger.fatal message
      if report.nil? || report.author.nil?
        AppMailer.system_error(message).deliver
      else
        ReportMailer.report_error(report.author.email, report.name || "", message).deliver
      end
    end
  
  end
end
