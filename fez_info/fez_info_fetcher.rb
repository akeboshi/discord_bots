require 'httpclient'
require 'json'
require 'nokogiri'
require 'yaml'

class FezInfo
  attr_accessor :id, :subject, :detail, :url, :category_str, :create_at

  def initialize(id, subject, detail, url, category_str, create_at)
    @id = id
    @subject = subject
    @detail = detail
    @url = url
    @category_str = category_str
    @create_at = create_at
  end

  def title
    "【#{category_str}: #{create_at}】#{subject}"
  end

  def to_s
    str = "【#{category_str}: #{create_at}】#{subject}\n"
    str += "詳細: #{url}\n"
    str += "```\n#{detail}\n```\n"
    str
  end
end

class FezInfoFetcher
  FEZ_URL = 'http://www.fantasy-earth.com/'.freeze
  FEZ_NEWS_URL = 'http://www.fantasy-earth.com/news/detail.php'.freeze
  FEZ_STORE_FILE = "#{File.expand_path(File.dirname(__FILE__))}/fezdata.yml".freeze
  @fezdata = []

  def initialize
    @client = HTTPClient.new
    if File.exist?(FEZ_STORE_FILE)
      load_fezdata
    else
      @fezdata = fetch_news_fezdata[1..-1]
      save_fezdata(@fezdata)
    end
  end

  def fetch
    data = latest_data
    fInfo = data.each.with_object([]) do |d, infos|
      infos.push(FezInfo.new(d["id"],
                             d["subject"],
                             news_detail_str(d["id"]),
                             news_detail_url(d["id"]),
                             d["category_str"],
                             d["created_at"]))
    end
    update_fezdata(data)
    fInfo
  end

  private

  def latest_data
    fetch_news_fezdata - @fezdata
  end
    
  def news_detail_str(id)
    res = @client.get(news_detail_url(id))
    doc = Nokogiri::HTML.parse(res.body, nil)
    
    doc.xpath("//div[@id='news-detail-content']")[0].content
  end

  def news_detail_url(id)
    "#{FEZ_NEWS_URL}?id=#{id}"
  end

  def fetch_news_fezdata
    res = @client.get(FEZ_URL)
    
    news = ""
    res.body.each_line do |line|
      news = line if line.match "newsJson"
    end
    
    JSON.parse(news.match(/newsJson = '(.*)';/)[1])
  end

  def update_fezdata(fezdata)
    @fezdata.concat(fezdata).uniq!
    save_fezdata(@fezdata)
  end
  
  def save_fezdata(fezdata)
    File.open(FEZ_STORE_FILE, "w") do |f|
      YAML.dump(fezdata, f)
    end
  end

  def load_fezdata
    @fezdata = YAML.load_file(FEZ_STORE_FILE)
  end
end
