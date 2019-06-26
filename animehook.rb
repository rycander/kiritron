#!/usr/bin/ruby

require 'uri'
require 'net/http'
require 'json'

def postPrepwork
  uri = URI.parse getSecrets['testWebhook']
  req = Net::HTTP::Post.new uri.path, initheader = {'Content-Type' => 'application/json'}
  
end

def getSecrets
  readJSONFile './secrets.json'
end

def getAnime
  readJSONFile './anime.json'
end

def getBody
  body = {"content"=> "HAHAHAH! TIME FOR PREPWORK", "embeds"=> []}
  anime = getAnime
  anime.each do |item|
    embed = {
      "title"=>item.name,
      "description"=>"Episode #{item.ep}"
      "url"=>item.url,
      "thumbnail"=> {
        "url"=>item.image
      }
    }

end

def readJSONFile path
  file = File.open path
  data = JSON.load file
  file.close
  data
end

