require 'crawlbase'
require 'parallel'
require 'logger'
require 'dotenv/load'
require 'fileutils'

class CrawlerPusher
  def initialize(asin_file, max_threads = 10)
    @client = Crawlbase::API.new(token: ENV['CRAWLBASE_API_KEY'])
    @asin_file = asin_file
    @max_threads = max_threads
    @logger = Logger.new('logs/crawler_pusher.log', 'daily')
  end

  def push_asins
    asins = File.readlines(@asin_file).map(&:chomp)
    Parallel.each(asins, in_threads: @max_threads) do |asin|
      begin
        url = "https://www.amazon.com/dp/#{asin}"
        response = @client.get(url, { store: true })
        @logger.info("Pushed ASIN #{asin}: #{response.status_code}, Response: #{response.body[0..100]}...")
      rescue => e
        @logger.error("Error pushing ASIN #{asin}: #{e.message}")
      end
    end
  end
end

asin_file = 'asins.txt'
crawler_pusher = CrawlerPusher.new(asin_file)
crawler_pusher.push_asins
