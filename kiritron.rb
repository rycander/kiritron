#!/usr/bin/ruby

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class Kiritron
  def initialize
    @secret = readJSONFile("secrets")["hookURI"]
    @anime = readJSONFile "anime"
    @image = File.readlines("#{__dir__}/images.txt").sample.strip
    @title = File.readlines("#{__dir__}/titles.txt").sample.strip
    @paheData = {}
  end

  def sendPrepwork
    postRequest @secret, getBody

    updateAnime
  end

  def requestMultiple
    @paheData = {}
    threads = @anime
      .select { |item| item.key? 'pahe'}
      .each_with_index.map do |item, i|
        Thread.new {
          @paheData[i] = JSON.load(getRequest(paheURI item['pahe']))['data']
        }
      end
    threads.each do |thread|
      thread.join
    end
  end

  def format
    file = File.open "#{__dir__}/anime.json", "w"
    file.write JSON.pretty_generate @anime 
    file.close
  end

  private

  def postRequest unparsedUri, body
    uri = URI.parse unparsedUri
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = body if !body.nil?
    puts req.body
    res = https.request(req)
    puts "Response #{res.code} #{res.message}: #{res.body}"
  end

  def getRequest unparsedUri
    uri = URI unparsedUri
    res = Net::HTTP.get uri
  end

  def parsePaheData data
    data.each do json
      item = JSON.load json
      @paheData[item['anime_id']] = {
        'uri' => ""
      }
    end
  end

  def paheURI id
    "https://animepahe.com/api?m=release&id=#{id}&l=30&sort=episode_desc&page=1"
  end

  def updateAnime
    @anime.each do |item|
      item['ep'] = 1 + item["ep"].to_i
    end

    file = File.open "#{__dir__}/anime.json", 'w'
    file.write @anime.to_json
    file.close
  end

  def getBody
    body = {
      "content"=> "HAHAHAH! TIME FOR PREPWORK!\n#{@title}",
      "embeds"=> [{
        "image" => {
          "url" => @image
        }
      }]
    }
    @anime.each_with_index do |item, i|
      embed = {
        "title"=>item['name'],
        "description"=>"Episode #{item['ep']}",
        "url"=>item['url'],
        "thumbnail"=> {
          "url"=>item['img']
        }
      }
      paheItem = getPaheEpisode i, item['ep']
      if !paheItem.nil?
        embed["thumbnail"] = {
          "url" => paheItem['snapshot']
        }
        embed["url"] = "https://animepahe.com/play/#{paheItem['anime_slug']}/#{paheItem['session']}"
      end

      body["embeds"].push embed
    end
    puts body
    body.to_json
  end

  def getPaheEpisode i, ep
    return if @paheData[i].nil?
    episode = @paheData[i].detect do |item|
      item['episode'].to_i == ep
    end
  end
end

private def  readJSONFile path
  file = File.open "#{__dir__}/#{path}.json"
  data = JSON.load file
  file.close
  data
end

kt = Kiritron.new

ARGV.each do |a|
  if a == 'f'
    kt.format
    exit
  end
end 

kt.requestMultiple
kt.sendPrepwork

