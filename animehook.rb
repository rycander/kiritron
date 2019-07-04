#!/usr/bin/ruby

require 'uri'
require 'net/http'
require 'net/https'
require 'json'

def postPrepwork
  uri = URI.parse getSecrets['test_webhook']
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new uri.path, initheader = {'Content-Type' =>'application/json'}
  req.body = getBody
  puts req.body
  res = https.request(req)

  updateAnime
end

def getSecrets
  readJSONFile "#{__dir__}/secrets.json"
end

def getAnime
  readJSONFile "#{__dir__}/anime.json"
end

def updateAnime
  anime = getAnime
  anime.each do |item|
    item["ep"] = 1 + item["ep"]
  end

  file = File.open "#{__dir__}/anime.json", 'w'
  file.write anime.to_json
  file.close
end

def getBody
  body = {
    "content"=> "HAHAHAH! TIME FOR PREPWORK!#{getTitle}",
    "embeds"=> [getImageEmbed]
  }
  getAnime.each do |item|
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

def getImageEmbed
  {
    "image" => {
      "url": "https://cdn.discordapp.com/attachments/294543539553959947/592911897120997376/image0.jpg"
    }
  }
end

def getTitle
  readJSONFile "#{__dir__}/titles.txt"
end

def readJSONFile path
  file = File.open path
  data = JSON.load file
  file.close
  data
end

postPrepwork
