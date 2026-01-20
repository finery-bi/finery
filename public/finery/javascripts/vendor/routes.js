var Routes = {
  run_queries_path: function() {
    return rootPath + "queries/run"
  },
  cancel_queries_path: function() {
    return rootPath + "queries/cancel"
  },
  schema_queries_path: function(params) {
    return rootPath + "queries/schema?" + $.param(params)
  },
  docs_queries_path: function(params) {
    return rootPath + "queries/docs?" + $.param(params)
  },
  tables_queries_path: function(params) {
    return rootPath + "queries/tables?" + $.param(params)
  },
  queries_path: function() {
    return rootPath + "queries"
  },
  query_path: function(id) {
    return rootPath + "queries/" + id
  },
  dashboard_path: function(id) {
    return rootPath + "dashboards/" + id
  },
  // AI routes
  ai_generate_sql_path: function() {
    return rootPath + "ai/generate_sql"
  },
  ai_explain_path: function() {
    return rootPath + "ai/explain"
  },
  ai_fix_error_path: function() {
    return rootPath + "ai/fix_error"
  },
  ai_summarize_path: function() {
    return rootPath + "ai/summarize"
  },
  ai_suggest_optimizations_path: function() {
    return rootPath + "ai/suggest_optimizations"
  },
  ai_status_path: function() {
    return rootPath + "ai/status"
  }
}
