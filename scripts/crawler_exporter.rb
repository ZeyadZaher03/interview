require 'json'
require 'csv'
require 'logger'

class CrawlerExporter
  def initialize(json_dir, output_file)
    @json_dir = json_dir
    @output_file = output_file
    @logger = Logger.new('logs/crawler_exporter.log', 'daily')
  end

  def export_to_csv
    json_files = Dir.glob(File.join(@json_dir, '*.json'))
    CSV.open(@output_file, 'w') do |csv|
      headers = ["url", "status_code", "title", "description", "price", "rating", "availability", "stored_at"]
      csv << headers

      json_files.each do |file|
        begin
          content = File.read(file)
          data = JSON.parse(content)
          csv << [data["url"], data["status_code"], data["title"], data["description"], data["price"], data["rating"], data["availability"], data["stored_at"]]
          @logger.info("Exported #{file} to CSV")
        rescue JSON::ParserError => e
          @logger.error("JSON parsing error for #{file}: #{e.message}")
        rescue => e
          @logger.error("Error exporting #{file}: #{e.message}")
        end
      end
    end
  end
end

json_dir = 'data'
output_file = 'output.csv'
crawler_exporter = CrawlerExporter.new(json_dir, output_file)
crawler_exporter.export_to_csv
