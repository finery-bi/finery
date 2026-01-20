# frozen_string_literal: true

module Blazer
  module Ai
    module Prompts
      class << self
        def generate_sql(prompt, schema_context, adapter)
          <<~PROMPT
            You are a SQL expert. Generate a #{adapter_description(adapter)} query based on the user's request.

            DATABASE SCHEMA:
            #{schema_context}

            USER REQUEST:
            #{prompt}

            RULES:
            - Return ONLY the SQL query, no explanations
            - Use proper #{adapter_description(adapter)} syntax
            - Use appropriate JOINs when multiple tables are involved
            - Include reasonable LIMIT if not specified (default 100)
            - Use aliases for readability
            - Handle NULL values appropriately

            SQL:
          PROMPT
        end

        def explain_query(sql, adapter)
          <<~PROMPT
            Explain what this #{adapter_description(adapter)} query does in simple, non-technical terms.
            Focus on the business logic and what data it retrieves.

            QUERY:
            #{sql}

            Provide a clear, concise explanation (2-4 sentences) that a non-technical person could understand.
          PROMPT
        end

        def fix_error(sql, error_message, schema_context, adapter)
          <<~PROMPT
            You are a SQL expert. Fix the following #{adapter_description(adapter)} query that produced an error.

            ORIGINAL QUERY:
            #{sql}

            ERROR MESSAGE:
            #{error_message}

            DATABASE SCHEMA:
            #{schema_context}

            RULES:
            - Return ONLY the corrected SQL query, no explanations
            - Fix the specific error while preserving the query's intent
            - Use proper #{adapter_description(adapter)} syntax

            CORRECTED SQL:
          PROMPT
        end

        def summarize_results(columns, sample_rows, total_rows, sql = nil)
          data_preview = format_data_preview(columns, sample_rows)

          <<~PROMPT
            Analyze these query results and provide a brief, insightful summary.

            #{sql ? "QUERY:\n#{sql}\n\n" : ""}COLUMNS: #{columns.join(", ")}

            DATA PREVIEW (#{sample_rows.size} of #{total_rows} rows):
            #{data_preview}

            Provide a 2-3 sentence summary highlighting:
            - Key patterns or trends
            - Notable values (max, min, outliers)
            - Business-relevant insights

            Be specific with numbers. Don't describe the data structure, describe what the data tells us.
          PROMPT
        end

        def suggest_optimizations(sql, explain_output, adapter)
          <<~PROMPT
            You are a database performance expert. Analyze this #{adapter_description(adapter)} query and suggest optimizations.

            QUERY:
            #{sql}

            #{explain_output ? "EXPLAIN OUTPUT:\n#{explain_output}\n" : ""}

            Provide specific, actionable suggestions:
            1. Index recommendations (if applicable)
            2. Query structure improvements
            3. Potential performance issues

            Be concise and practical. Only suggest changes that would have meaningful impact.
          PROMPT
        end

        def suggest_followups(sql, columns, sample_rows, adapter)
          data_preview = format_data_preview(columns, sample_rows.first(10))

          <<~PROMPT
            Based on this #{adapter_description(adapter)} query and its results, suggest 3 follow-up queries the user might want to run.

            ORIGINAL QUERY:
            #{sql}

            RESULT COLUMNS: #{columns.join(", ")}

            DATA PREVIEW:
            #{data_preview}

            Suggest 3 natural follow-up questions in plain English (not SQL). Format as a numbered list:
            1. [suggestion]
            2. [suggestion]
            3. [suggestion]
          PROMPT
        end

        private

        def adapter_description(adapter)
          case adapter.to_s.downcase
          when /postgres/, /redshift/
            "PostgreSQL"
          when /mysql/, /trilogy/
            "MySQL"
          when /sqlite/
            "SQLite"
          when /sqlserver/
            "SQL Server"
          when /bigquery/
            "BigQuery"
          when /snowflake/
            "Snowflake"
          when /athena/
            "Amazon Athena"
          when /presto/
            "Presto"
          else
            "SQL"
          end
        end

        def format_data_preview(columns, rows)
          return "No data" if rows.empty?

          rows.map do |row|
            columns.zip(row).map { |col, val| "#{col}: #{val.inspect}" }.join(", ")
          end.join("\n")
        end
      end
    end
  end
end
