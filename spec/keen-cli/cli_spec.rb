require 'spec_helper'

describe KeenCli::CLI do

  let(:project_id) { 'AAAAAAA' }
  let(:master_key) { 'DDDDDD' }
  let(:read_key) { 'BBBBBB' }
  let(:write_key) { 'CCCCCC' }

  def start(str=nil)
    KeenCli::CLI.start(str ? str.split(" ") : [])
  end

  before do
    Keen.project_id = project_id
    Keen.read_key = read_key
    Keen.write_key = write_key
    Keen.master_key = master_key
  end

  it 'prints help by default' do
    _, options = start
    expect(_).to be_empty
  end

  it 'prints version info if -v is used' do
    _, options = start "-v"
    expect(_).to match /version/
  end

  describe 'project:describe' do
    it 'gets the project' do
      url = "https://api.keen.io/3.0/projects/#{project_id}"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:describe'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:describe --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end

  describe 'project:collections' do
    it 'prints the project\'s collections' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:collections'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:collections --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end

  describe 'queries:run' do
    it 'runs the query using certain params' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths'
      expect(_).to eq(10)
    end

    it 'runs the query using aliased params' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run -a count -c minecraft-deaths'
      expect(_).to eq(10)
    end

    it 'converts dashes to underscores for certain properties' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&group_by=foo&target_property=bar"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths --group-by foo --target-property bar'
      expect(_).to eq(10)
    end

    it 'accepts extraction-specific properties' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/extraction?event_collection=minecraft-deaths&property_names=%5B%22foo%22,%22bar%22%5D&latest=1&email=bob@bob.io"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type extraction --collection minecraft-deaths --property-names foo,bar --latest 1 --email bob@bob.io'
      expect(_).to eq(10)
    end

    it 'converts comma-delimited property names to an array' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/extraction?event_collection=minecraft-deaths&property_names=%5B%22foo%22,%22bar%22%5D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type extraction --collection minecraft-deaths --property-names foo,bar'
      expect(_).to eq(10)
    end


    it 'uses a data option to take in query JSON' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --data {"event_collection":"minecraft-deaths"}'
      expect(_).to eq(10)
    end

    it 'converts a start parameter into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22start%22:%222014-07-06T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --start 2014-07-06T12:00:00Z'
      expect(_).to eq(10)
    end

    it 'converts an end parameter into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22end%22:%222014-07-06T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --end 2014-07-06T12:00:00Z'
      expect(_).to eq(10)
    end

    it 'converts start and end parameters into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22start%22:%222014-07-06T12:00:00Z%22,%22end%22:%222014-07-08T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --start 2014-07-06T12:00:00Z --end 2014-07-08T12:00:00Z'
      expect(_).to eq(10)
    end

  end

  describe "queries:run aliases" do
    KeenCli::CLI::ANALYSIS_TYPES.each do |analysis_type|
      describe analysis_type do
        it "aliases to queries run, passing along the #{analysis_type} analysis type" do
          underscored_analysis_type = analysis_type.sub('-', '_')
          url = "https://api.keen.io/3.0/projects/#{project_id}/queries/#{underscored_analysis_type}?event_collection=minecraft-deaths"
          stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
          _, options = start "#{analysis_type} --collection minecraft-deaths"
          expect(_).to eq(10)
        end
      end
    end
  end

  describe 'events:add' do
    it 'should accept JSON events from a data param' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events/minecraft-deaths"
      stub_request(:post, url).
        with(:body => { "foo" => 1 }).
        to_return(:body => { :created => true }.to_json)
      _, options = start 'events:add --collection minecraft-deaths --data {"foo":1}'
      expect(_).to eq("created" => true)
    end

    it 'should accept JSON events from a file param' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events/minecraft-deaths"
      stub_request(:post, "https://api.keen.io/3.0/projects/AAAAAAA/events").
        with(:body => "{\"minecraft-deaths\":[{\"foo\":1},{\"foo\":2},{\"foo\":3}]}").
        to_return(:body => { :created => true }.to_json)
      _, options = start "events:add --collection minecraft-deaths --file #{File.expand_path('../../fixtures/events.json', __FILE__)}"
      expect(_).to eq("created" => true)
    end

    it 'should accept JSON events from a file param in CSV format' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events/minecraft-deaths"
      stub_request(:post, "https://api.keen.io/3.0/projects/AAAAAAA/events").
        with(:body => "{\"minecraft-deaths\":[{\"foo\":1,\"keen\":{\"timestamp\":\"2014-07-28T15:03:10-04:00\"}},{\"foo\":2,\"keen\":{\"timestamp\":\"2014-07-28T17:12:32-04:00\"}},{\"foo\":3,\"keen\":{\"timestamp\":\"2014-07-28T17:12:44-04:00\"}}]}").
        to_return(:body => { :created => true }.to_json)
      _, options = start "events:add --collection minecraft-deaths --csv --file #{File.expand_path('../../fixtures/events.csv', __FILE__)}"
      expect(_).to eq("created" => true)
    end
  end
end
