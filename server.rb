require "sinatra"

require "sinatra/reloader" if development?
require "pry" if development? || test?
require "csv"

require_relative "models/article.rb"

set :bind, '0.0.0.0'  # bind to all interfaces

get "/" do
  redirect "/articles"
end

get "/articles" do
  @article_objects = []

  CSV.foreach("articles.csv", headers: true) do |row|
    new_article = Article.new(
      row["id"],
      row["title"],
      row["description"],
      row["url"],
    )
    @article_objects << new_article
  end

  erb :index
end

get "/new" do
  redirect "/articles/new"
end

get "/articles/new" do
  erb :new
end

post "/articles" do
  id = retrieve_articles.last.id.to_i + 1
  @title = params["title"]
  @description = params["description"]
  @url = params["url"]
  @table = CSV.parse(File.read("articles.csv"), headers: true)

  if @title != "" && @description != "" && @description.length >= 20 && @url != "" && @url.include?("http") && !@table.by_col[3].include?(@url)
    CSV.open("articles.csv", "a") do |csv_file|
      csv_file << [@id, @title, @description, @url]
      end
      redirect "/articles"
  else
    @errors = "Error!<br>"

    if @title.strip == ""
      @errors += "Please enter a title.<br>"
    end

    if @description.strip == "" || @description.length < 20
      @errors += "Please enter a description longer than 20 characters.<br>"
    end

    if @url.strip == "" || !@url.include?("http")
      @errors += "Please enter a valid URL, including HTTP.<br>"
    end

    if @table.by_col[3].include?(@url)
      @errors += "This article has already been posted. Please don't plagiarize!<br>"
    end

  end
  erb :new
end

def retrieve_articles
  article_objects = []

  CSV.foreach("articles.csv", headers: true) do |row|
    new_article = Article.new(
      row["id"],
      row["title"],
      row["description"],
      row["url"],
    )
    article_objects << new_article
  end
  article_objects
end

get "/articles/:id" do
  id = params["id"]
  article_objects = []

  CSV.foreach("articles.csv", headers: true) do |row|
    new_article = Article.new(
      row["id"],
      row["title"],
      row["description"],
      row["url"]
    )

    article_objects << new_article
  end

  article_objects.each do |article|
    if article.id == id
      @article = article
    end
  end

  erb :show
end
