# Amazon Product Data Crawler Using Crawlbase

This project is a Ruby-based web crawler system utilizing Crawlbase to extract Amazon product data. The system consists of three main components: Crawler Pusher, Crawler Puller, and Crawler Exporter.

## Components

### 1. Crawler Pusher
Fetches Amazon ASIN URLs from a text file and pushes them to Crawlbase using parallelism.

### 2. Crawler Puller
Continuously fetches parsed ASIN pages from Crawlbase Storage and extracts useful data.

### 3. Crawler Exporter
Converts the fetched JSON data into a CSV file.

## File Structure
```
/app
├── /data
├── /logs
├── /scripts
│ ├── crawler_exporter.rb
│ ├── crawler_puller.rb
│ ├── crawler_pusher.rb
├── .env
├── asins.txt
├── docker-compose.yml
├── Gemfile
├── Gemfile.lock
├── output.csv
```

## Setup and Usage

### Prerequisites
- Docker
- Docker Compose

### Environment Variables
Create a `.env` file with your Crawlbase API key:
```
CRAWLBASE_API_KEY=your_api_key_here
```

### Running the Project in Docker

1. **Build the Docker image:**
```
  docker-compose build
```
2. **Run all services:**
```
  docker-compose up
```
3. **Run all services:**
```
  docker-compose crawler_pusher
```
4. **Run all services:**
```
  docker-compose crawler_puller
```
3. **Manually run the exporter:**
```
  docker-compose run crawler_exporter
```

## Logic for Each Script
### crawler_pusher.rb
Fetches ASINs from asins.txt and pushes them to Crawlbase using parallel threads.

- Initialize: Sets up the Crawlbase client and logger.
- push_asins: Reads ASINs, pushes them in parallel, and logs the responses.

### crawler_puller.rb
Fetches data from Crawlbase Storage at regular intervals and saves the relevant information in JSON format.

- Initialize: Sets up the Crawlbase client, output directory, and logger.
- fetch_data: Continuously fetches RIDs from Crawlbase Storage.
- fetch_and_save_data: Fetches data for each RID, parses the HTML to extract relevant fields, and saves it as a JSON file.

### crawler_exporter.rb
Reads JSON files and exports the data to a CSV file.

- Initialize: Sets up the JSON directory, output file, and logger.
- export_to_csv: Reads JSON files, extracts data, and writes it to a CSV file with headers.

# Example Usage
To use the scripts, populate asins.txt with the desired ASINs, and ensure your .env file contains the CRAWLBASE_API_KEY. Then, follow the Docker instructions above to run the services.
