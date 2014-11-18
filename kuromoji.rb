require 'sinatra'
require 'sinatra/json'

def translate_type(type)
  if type == "動詞"
    "verb"
  elsif type == "名詞"
    "noun"
  else
    "others"
  end
end

def parse_token(token)
  split_token = token.split("\t")
  token_name = split_token[0]

  attributes = split_token[1].split(",")
  word_type = attributes[0]
  dict_form = attributes[6]

  result = {}
  result["plain"] = dict_form
  result["tag"] = translate_type(word_type)
  result["original"] = token_name

  result
end

post '/' do
  content_type :json

  command = "java -Dfile.encoding=UTF-8 -cp kuromoji-0.7.7/lib/kuromoji-0.7.7.jar:kuromoji-0.7.7/src/main/java org.atilika.kuromoji.example.TokenizerExample #{params["input"]}"
  output = `#{command}`

  tokens = output.split("\n")

  result_json = {}
  result_json["input"] = tokens[0]
  parsed_tokens = []
  tokens = tokens[1..tokens.size]
  tokens.each do |token|
    parsed_token = parse_token(token)
    parsed_tokens << parsed_token
  end

  result_json["tokens"] = parsed_tokens
  json result_json
end
