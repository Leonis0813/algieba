module PaymentHelper
  def category_names
    Payment.joins(:categories).group('categories.name').order('count_all desc')
           .count.keys
  end

  def tag_names
    Payment.joins(:tags).group('tags.name').order('count_all desc')
           .count.keys
  end
end
