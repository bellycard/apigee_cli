require 'spec_helper'
require 'apigee_cli/config_set'

describe ApigeeCli::ConfigSet do
  let(:config_set)  { ApigeeCli::ConfigSet.new }
  let(:environment) { ApigeeCli.configuration.environment }
  let(:org)         { ApigeeCli.configuration.org }

  let(:base_url)    { "https://api.enterprise.apigee.com/v1/o/#{org}/environments/#{environment}/keyvaluemaps" }
  let(:config_name) { 'configuration' }
  let(:data) {
    [{
       name: 'key_one',
       value: 'value_one'
     },
     {
       name: 'key_two',
       value: 'value_two'
     }]
  }

  let(:body) { { name: config_name, entry: data } }

  let(:key_value_map) {
    {
      keyValueMap: [
        entry: data,
        name: 'configuration'
      ]
    }
  }

  describe '#base_url' do
    it 'points to Apigee\'s keyvaluemaps endpoint' do
      expect(config_set.base_url).to eq base_url
    end
  end

  describe '#list_configs' do
    it 'GETs a list of all keyvaluemaps' do
      expect(config_set).to receive(:get).with(base_url, expand: true).and_return(
        Hashie::Mash.new(
          body: key_value_map.to_json,
          status: 200
        )
      )

      response = config_set.list_configs
    end

    it 'throws an error if response status is not 200' do
      allow(config_set).to receive(:get).with(base_url).and_return(
        Hashie::Mash.new(
          body: {}.to_json,
          status: 500
        )
      )

      expect { config_set.list_configs }.to raise_error
    end
  end

  describe '#read_config' do
    it 'GETs a list of keyvaluemaps at requested config_name' do
      base_url_with_name = [base_url, config_name].join('/')

      expect(config_set).to receive(:get).with("#{base_url}/#{config_name}").and_return(
        Hashie::Mash.new(
          body: key_value_map[:keyValueMap].to_json,
          status: 200
        )
      )

      response = config_set.read_config(config_name)
    end
  end

  describe '#write_config' do
    it 'POSTs keyvaluemaps for a config_name' do
      expect(config_set).to receive(:post).with(base_url, body).and_return(
        Hashie::Mash.new(
          body: key_value_map[:keyValueMap].to_json,
          status: 201
        )
      )

      config_set.write_config(config_name, data)
    end
  end

  describe '#update_config' do
    it 'PUTs keyvaluemaps for a config_name' do
      base_url_with_name = [base_url, config_name].join('/')

      expect(config_set).to receive(:put).with(base_url_with_name, body).and_return(
        Hashie::Mash.new(
          body: key_value_map[:keyValueMap].to_json,
          status: 200
        )
      )

      config_set.update_config(config_name, data)
    end
  end

  describe '#remove_config' do
    it 'DELETEs keyvaluemaps for a config_name' do
      base_url_with_name = [base_url, config_name].join('/')

      expect(config_set).to receive(:delete).with(base_url_with_name).and_return(
        Hashie::Mash.new(
          body: key_value_map[:keyValueMap].to_json,
          status: 200
        )
      )

      config_set.remove_config(config_name)
    end
  end

  describe '#remove_entry' do
    it 'DELETEs a key from keyvaluemaps for a config_name' do
      entry_name = 'key_one'
      base_url_with_name = [base_url, config_name, 'entries', entry_name].join('/')

      expect(config_set).to receive(:delete).with(base_url_with_name).and_return(
        Hashie::Mash.new(
          body: { name: entry_name, value: data.first[entry_name] }.to_json,
          status: 200
        )
      )

      config_set.remove_entry(config_name, entry_name)
    end
  end
end
