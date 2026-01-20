# frozen_string_literal: true

module Blazer
  module Ai
    class Service
      attr_reader :data_source, :model

      def initialize(data_source)
        @data_source = data_source
        @model = Blazer.ai_model
      end

      # Generate SQL from natural language
      def generate_sql(prompt)
        schema_context = build_schema_context

        response = chat.ask(Prompts.generate_sql(prompt, schema_context, adapter_name))
        extract_sql(response.content)
      end

      # Explain what a SQL query does in plain language
      def explain_query(sql)
        response = chat.ask(Prompts.explain_query(sql, adapter_name))
        response.content
      end

      # Fix a SQL error
      def fix_error(sql, error_message)
        schema_context = build_schema_context

        response = chat.ask(Prompts.fix_error(sql, error_message, schema_context, adapter_name))
        extract_sql(response.content)
      end

      # Summarize query results
      def summarize_results(columns, rows, sql: nil)
        return nil if rows.empty?

        # Limit rows for context window
        sample_rows = rows.first(50)

        response = chat.ask(Prompts.summarize_results(columns, sample_rows, rows.size, sql))
        response.content
      end

      # Suggest optimizations based on query and explain plan
      def suggest_optimizations(sql, explain_output = nil)
        response = chat.ask(Prompts.suggest_optimizations(sql, explain_output, adapter_name))
        response.content
      end

      # Generate follow-up query suggestions
      def suggest_followups(sql, columns, sample_rows)
        response = chat.ask(Prompts.suggest_followups(sql, columns, sample_rows, adapter_name))
        parse_suggestions(response.content)
      end

      private

      def chat
        @chat ||= RubyLLM.chat(model: model)
      end

      def adapter_name
        @adapter_name ||= data_source.adapter
      end

      def build_schema_context
        tables = data_source.tables
        return "No schema information available." if tables.empty?

        schema_info = tables.map do |table|
          columns = begin
            data_source.schema[table] || []
          rescue
            []
          end

          if columns.any?
            column_list = columns.map { |c| "  - #{c[:name]} (#{c[:type]})" }.join("\n")
            "#{table}:\n#{column_list}"
          else
            table
          end
        end

        schema_info.join("\n\n")
      end

      def extract_sql(content)
        # Try to extract SQL from markdown code blocks
        if content =~ /```sql\s*(.*?)\s*```/mi
          $1.strip
        elsif content =~ /```\s*(.*?)\s*```/mi
          $1.strip
        else
          # If no code blocks, assume the entire response is SQL
          content.strip.gsub(/^(Here'?s?|The|This|I've|Below).*?:\s*/i, "").strip
        end
      end

      def parse_suggestions(content)
        # Parse numbered list of suggestions
        suggestions = []
        content.scan(/\d+\.\s*(.+?)(?=\n\d+\.|\n\n|$)/m) do |match|
          suggestions << match[0].strip
        end
        suggestions.presence || [content.strip]
      end
    end
  end
end
