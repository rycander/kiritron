#!/usr/bin/ruby

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class Kiritron
  def initialize
    @secret = readJSONFile("secrets")['hookURI']
    @anime = readJSONFile 'anime'
    @image = File.readlines("#{__dir__}/images.txt").sample.strip
    @title = File.readlines("#{__dir__}/titles.txt").sample.strip
  end

  def sendPrepwork
    uri = URI.parse @secret
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = getBody
    puts req.body
    res = https.request(req)
    puts "Response #{res.code} #{res.message}: #{res.body}"

    updateAnime
  end

  private

  def updateAnime
    @anime.each do |item|
      item["ep"] = 1 + item["ep"].to_i
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
          "url": @image
        }
      }]
    }
    @anime.each do |item|
      embed = {
        "title"=>item["name"],
        "description"=>"Episode #{item["ep"]}",
        "url"=>item["url"],
        "thumbnail"=> {
          "url"=>item["img"]
        }
      }
      body["embeds"].push embed
    end
    body.to_json
  end
end

private def  readJSONFile path
  file = File.open "#{__dir__}/#{path}.json"
  data = JSON.load file
  file.close
  data
end

kt = Kiritron.new
kt.sendPrepwork

