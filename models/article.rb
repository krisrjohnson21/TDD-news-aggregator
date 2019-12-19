class Article
  attr_reader :id, :title, :description, :url

  def initialize(id, title, description, url)
    @id = id
    @title = title
    @description = description
    @url = url
  end
end
