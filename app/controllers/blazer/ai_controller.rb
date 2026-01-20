# frozen_string_literal: true

module Blazer
  class AiController < BaseController
    before_action :check_ai_enabled

    # POST /ai/generate_sql
    def generate_sql
      prompt = params.require(:prompt)
      data_source = Blazer.data_sources[params[:data_source] || "main"]

      service = Blazer::Ai.service(data_source)
      sql = service.generate_sql(prompt)

      render json: { sql: sql }
    rescue Blazer::Ai::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "[Blazer AI] generate_sql error: #{e.message}"
      render json: { error: "AI service error. Please try again." }, status: :internal_server_error
    end

    # POST /ai/explain
    def explain
      sql = params.require(:sql)
      data_source = Blazer.data_sources[params[:data_source] || "main"]

      service = Blazer::Ai.service(data_source)
      explanation = service.explain_query(sql)

      render json: { explanation: explanation }
    rescue Blazer::Ai::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "[Blazer AI] explain error: #{e.message}"
      render json: { error: "AI service error. Please try again." }, status: :internal_server_error
    end

    # POST /ai/fix_error
    def fix_error
      sql = params.require(:sql)
      error_message = params.require(:error_message)
      data_source = Blazer.data_sources[params[:data_source] || "main"]

      service = Blazer::Ai.service(data_source)
      fixed_sql = service.fix_error(sql, error_message)

      render json: { sql: fixed_sql }
    rescue Blazer::Ai::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "[Blazer AI] fix_error error: #{e.message}"
      render json: { error: "AI service error. Please try again." }, status: :internal_server_error
    end

    # POST /ai/summarize
    def summarize
      columns = params.require(:columns)
      rows = params.require(:rows)
      sql = params[:sql]
      data_source = Blazer.data_sources[params[:data_source] || "main"]

      service = Blazer::Ai.service(data_source)
      summary = service.summarize_results(columns, rows, sql: sql)

      render json: { summary: summary }
    rescue Blazer::Ai::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "[Blazer AI] summarize error: #{e.message}"
      render json: { error: "AI service error. Please try again." }, status: :internal_server_error
    end

    # POST /ai/suggest_optimizations
    def suggest_optimizations
      sql = params.require(:sql)
      explain_output = params[:explain_output]
      data_source = Blazer.data_sources[params[:data_source] || "main"]

      service = Blazer::Ai.service(data_source)
      suggestions = service.suggest_optimizations(sql, explain_output)

      render json: { suggestions: suggestions }
    rescue Blazer::Ai::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "[Blazer AI] suggest_optimizations error: #{e.message}"
      render json: { error: "AI service error. Please try again." }, status: :internal_server_error
    end

    # GET /ai/status
    def status
      render json: {
        enabled: Blazer.ai?,
        model: Blazer.ai_model,
        ruby_llm_available: Blazer::Ai.ruby_llm_available?
      }
    end

    private

    def check_ai_enabled
      unless Blazer.ai?
        render json: { error: "AI features are not enabled" }, status: :forbidden
      end
    end
  end
end
