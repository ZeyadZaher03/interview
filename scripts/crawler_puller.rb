require 'crawlbase'
require 'logger'
require 'json'
require 'dotenv/load'
require 'fileutils'
require 'nokogiri'

class CrawlerPuller
  def initialize(output_dir, interval = 60)
    @client = Crawlbase::StorageAPI.new(token: ENV['CRAWLBASE_API_KEY'])
    @output_dir = output_dir
    @interval = interval
    @logger = Logger.new('logs/crawler_puller.log', 'daily')
    FileUtils.mkdir_p(@output_dir) unless Dir.exist?(@output_dir)
  end

  def fetch_data
    loop do
      begin
        response = @client.rids(100)
        rids = response['rids']
        @logger.debug("RIDs response: #{rids.inspect}")
        if rids && !rids.empty?
          rids.each do |rid|
            fetch_and_save_data(rid)
          end
        else
          @logger.warn("No RIDs found in response: #{response.inspect}")
        end
      rescue => e
        @logger.error("Error fetching data: #{e.message}")
      end
      sleep @interval
    end
  end

  private

  def fetch_and_save_data(rid)
    begin
      response = @client.get(rid)
      if response
        html_doc = Nokogiri::HTML(response.body)
        title = html_doc.at('title')&.text || "No Title Found"
        description = html_doc.at('meta[name="description"]')&.attr('content') || "No Description Found"
        price = html_doc.at('span#priceblock_ourprice')&.text || html_doc.at('span#priceblock_dealprice')&.text || "No Price Found"
        rating = html_doc.at('span#acrPopover')&.attr('title') || "No Rating Found"
        availability = html_doc.at('div#availability span')&.text.strip || "No Availability Info"

        data = {
          url: response.url,
          status_code: response.status_code,
          title: title,
          description: description,
          price: price,
          rating: rating,
          availability: availability,
          stored_at: response.stored_at
        }
        
        File.open(File.join(@output_dir, "#{rid}.json"), 'w') do |file|
          file.write(JSON.pretty_generate(data))
        end
        @logger.info("Fetched data for RID #{rid}")
      else
        @logger.warn("No data found for RID #{rid}")
      end
    rescue => e
      @logger.error("Error fetching data for RID #{rid}: #{e.message}")
    end
  end
end

output_dir = 'data'
crawler_puller = CrawlerPuller.new(output_dir)
crawler_puller.fetch_data
