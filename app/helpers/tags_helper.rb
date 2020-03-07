module TagsHelper
  def tag_names
    Tag.all.order(:name).pluck(:name)
  end
end
