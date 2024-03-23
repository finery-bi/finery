require_relative "test_helper"

class ChartsTest < ActionDispatch::IntegrationTest
  def test_line_chart_format1
    run_query "SELECT NOW(), 1"
    assert_match /data-chart-type-value="line"/, response.body
  end

  def test_line_chart_format2
    run_query "SELECT NOW(), 'Label' AS label, 1"
    assert_match /data-chart-type-value="line2"/, response.body
  end

  def test_column_chart_format1
    run_query "SELECT 'Label' AS label, 1"
    assert_match /data-chart-type-value="bar"/, response.body
  end

  def test_column_chart_format2
    run_query "SELECT 'Label' AS label, 'Group' AS group, 1"
    assert_match /data-chart-type-value="bar2"/, response.body
    assert_match %{"label":"Group"}, response.body
  end

  def test_scatter_chart
    run_query "SELECT 1, 2"
    assert_match /data-chart-type-value="scatter"/, response.body
  end

  def test_pie_chart
    run_query "SELECT 'Label', 1 AS pie"
    assert_match /data-chart-type-value="pie"/, response.body
  end

  def test_target
    run_query "SELECT NOW(), 1, 2 AS target"
    assert_match %{"label":"target"}, response.body
  end
end
