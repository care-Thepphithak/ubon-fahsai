module TrendComparison
  extend ActiveSupport::Concern

  def compare_counts(today, yesterday)
    if today > yesterday
      :increased
    elsif today < yesterday
      :decreased
    else
      :unchanged
    end
  end
end
