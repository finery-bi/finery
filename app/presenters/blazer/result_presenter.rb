class Blazer::ResultPresenter
  delegate :chart_type, :column_types, :smart_values, :columns, :rows, to: :result

  def initialize(result)
    @result = result
  end

  def chart_data
    case chart_type
    when "line" then format(line_data)
    when "line2" then format(line2_data)
    when "pie" then format(pie_data, labels: rows.map{ |r| smart_value(0, r[0]) })
    when "bar" then format(bar_data)
    when "bar2" then format(bar2_data)
    when "scatter" then format(scatter_data, x: columns[0], y: columns[1])
    end
  end

  private

  attr_reader :result

  def format(datasets, **options)
    if "time" == column_types.first
      datasets.each do |set|
        set[:data].each do |row|
        row[:x] = row[:x].strftime("%Q").to_i
      end
      end
    end
    { column_types: column_types, datasets: datasets, **options }
  end

  def series_name(name)
    name.nil? ? "null" : name.to_s
  end

  def smart_value(column, value)
    (smart_values[columns[column]] || {})[value.to_s] || value
  end

  def line_data
    columns.each_with_index.drop(1).map do |k, i|
      {
        label: series_name(k),
        data: rows.map{ |r| { x: r[0], y: r[i] }},
      }
    end
  end

  def line2_data
    unique = rows.group_by{ |r| smart_value(1, r[1]) }
    unique.map do |k, v|
      {
        label: series_name(k),
        data: v.map{ |r| { x: r[0], y: r[2] }},
      }
    end
  end

  def pie_data
    [{ data: rows.map{ |r| r[1] } }]
  end

  def bar_data
    columns.each_with_index.drop(1).map do |name, i|
      {
        label: series_name(name),
        data: rows.first(20).map{ |r| { x: smart_value(0, r[0]), y: r[i] }},
      }
    end
  end

  def bar2_data
    first_20 = rows.group_by{ |r| r[0] }.values.first(20).flatten(1)
    labels = first_20.map{ |r| r[0] }.uniq
    series = first_20.map{ |r| r[1] }.uniq
    labels.each do |l|
      series.each do |s|
        first_20 << [l, s, 0] unless first_20.find{ |r| r[0] == l && r[1] == s }
       end
     end
    unique_20 = first_20.group_by{ |r| smart_value(1, r[1]) }
    unique_20.each_with_index.map do |(name, v), i|
      values = v.sort_by{ |r2| labels.index(r2[0]) }
      {
        label: series_name(name),
        data: values.map{ |v2| { x: smart_value(0, v2[0]), y: v2[2] }},
      }
    end
  end

  def scatter_data
    [{ data: rows.map{ |r| { x: r[0], y: r[1] }} }]
  end
end
