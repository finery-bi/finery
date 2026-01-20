# frozen_string_literal: true

module Blazer
  module Ai
    class Error < Blazer::Error; end
    class ConfigurationError < Error; end
    class ProviderError < Error; end

    class << self
      def enabled?
        Blazer.ai_enabled && ruby_llm_available?
      end

      def ruby_llm_available?
        return @ruby_llm_available if defined?(@ruby_llm_available)
        @ruby_llm_available = begin
          require "ruby_llm"
          true
        rescue LoadError
          false
        end
      end

      def configure!
        return unless enabled?

        RubyLLM.configure do |config|
          ai_config = Blazer.settings.fetch("ai", {})

          # Configure all supported providers
          config.openai_api_key = ai_config["openai_api_key"] || ENV["OPENAI_API_KEY"]
          config.anthropic_api_key = ai_config["anthropic_api_key"] || ENV["ANTHROPIC_API_KEY"]
          config.gemini_api_key = ai_config["gemini_api_key"] || ENV["GEMINI_API_KEY"]
          config.deepseek_api_key = ai_config["deepseek_api_key"] || ENV["DEEPSEEK_API_KEY"]

          # Custom endpoint for Ollama or other OpenAI-compatible APIs
          if ai_config["openai_api_base"]
            config.openai_api_base = ai_config["openai_api_base"]
          end
        end
      end

      def service(data_source)
        raise ConfigurationError, "AI is not enabled" unless enabled?
        Service.new(data_source)
      end
    end

    autoload :Service, "blazer/ai/service"
    autoload :Prompts, "blazer/ai/prompts"
  end
end
