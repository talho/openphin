class Reporters::Reporter < Struct.new(:options)

  class Logger  # default dummy logger
    def info(t); end
    def fatal(t); end
  end

  def perform

    report_id = options[:report_id]
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
      if ( recipe = report.recipe )
        logger.info %Q(Report "#{report.name}", recipe is "#{report.recipe.class.name})
      else
        message = %Q(Report "#{report.name}" could not find recipe with id of #{report[:recipe_id]})
        raise StandardError, message
      end

        begin
          view_path = Rails::Configuration.new.view_path
          view = view_for_at_using author, view_path, recipe
        rescue StandardError => e
          message = %Q(Report "#{report.name}" erred in building supporting view: (#{e}))
          full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
          fatal_logging(logger,report,full_message)
        end

      unless options[:filters]
        begin
          start_time = Time.now
            recipe.bind_attributes( report )
          logger.info %Q(Report "#{report.name}", Bind Attributes #{Time.now-start_time} seconds)
          logger.info %Q(Report "#{report.name}" completed\n)
        rescue StandardError => e
          message = %Q(Report "#{report.name}" erred in binding attributes: (#{e}))
          full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
          fatal_logging(logger,report,full_message)
        end

        begin
          start_time = Time.now
            recipe.capture_to_db report
          logger.info %Q(Report "#{report.name}", Data Capture #{Time.now-start_time} seconds)
        rescue StandardError => e
          message = %Q(Report "#{report_id}" erred in capturing data: (#{e}))
          full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
          fatal_logging(logger,report,full_message)
        end

      end

      begin
        start_time = Time.now
          recipe.generate_rendering_of_on_with  report, view, File.read(recipe.template_path), options[:filters]
        logger.info %Q(Report "#{report.name}", Rendering HTML #{Time.now-start_time} seconds)
        ReportMailer.deliver_report_generated(report.author.email,report.name)
      rescue StandardError => e
        message = %Q(Report "#{report.name}" erred in rendering html: (#{e}))
        full_message = "#{message}\n#{e.backtrace.collect{|b| "#{b}\n"}}"
        fatal_logging(logger,report,full_message)
      end

    rescue StandardError => e
      fatal_logging(logger,report,e.message)
    end

  end

protected

  def view_for_at_using(owner,path,recipe)
    view = ActionView::Base.new path
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
      AppMailer.deliver_system_error(message)
    else
      ReportMailer.deliver_report_error(report.author.email, report.name || "", message)
    end
  end

end

