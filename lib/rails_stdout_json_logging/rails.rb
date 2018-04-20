require_relative 'json_formatter'

module RailsStdoutJsonLogging
  class StdoutLogger < defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger : ::Logger
    include ::LoggerSilence if defined?(::LoggerSilence)
  end

  class Rails
    def self.heroku_stdout_logger
      logger           = StdoutLogger.new(STDOUT)
      logger           = ActiveSupport::TaggedLogging.new(logger) if defined?(ActiveSupport::TaggedLogging)
      logger.formatter = JsonFormatter.new
      logger.level     = StdoutLogger.const_get(log_level)
      logger
    end

    def self.log_level
      ([(ENV['LOG_LEVEL'] || ::Rails.application.config.log_level).to_s.upcase, "INFO"] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]).compact.first
    end

    def self.set_logger
      STDOUT.sync = true
    end
  end
end
