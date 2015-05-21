#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'yaml'

conf = YAML.load_file(File.dirname(__FILE__) + '/config.yaml')

# Hotpepper
params = URI.encode_www_form({
  key: conf['recruit_key'],
  is_open_time: 'now',
  lat: conf['lat'],
  lng: conf['lng'],
  range: 2,
  lunch: 1,
  count: 100,
  format: 'json'
  })

uri = URI.parse("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?#{params}")

begin
  response = Net::HTTP.start(uri.host, uri.port) do |http|
    http.open_timeout = 5
    http.read_timeout = 10
    http.get(uri.request_uri)
  end

  case response
  when Net::HTTPSuccess
    data = JSON.parse(response.body)

    # ランダムで3つ
    shop = data['results']['shop'].sample(3)

    # post message
    mes = "<ul>"
    shop.each do |s|
      mes += "<li><b>#{s['name']}</b>: #{s['urls']['pc']}</li>"
    end
    mes += "</ul>"

    # idobataにPOST
    Net::HTTP.post_form(URI.parse(conf['hook']), {source: mes, format:'html'})
  end
end
