require 'sinatra'
require 'sinatra/json'
require 'json'
require 'pp'

DIRECTORY = "/Users/pohchiat/Dropbox/projects/kuromoji-web/"

if RUBY_VERSION =~ /1.9/ # assuming you're running Ruby ~1.9
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

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

  # parse form-data and call command
  input_json = JSON.parse(params["input"])
  command = "java -Dfile.encoding=UTF-8 -cp #{DIRECTORY}kuromoji-0.7.7/lib/kuromoji-0.7.7.jar:#{DIRECTORY}kuromoji-0.7.7/src/main/java org.atilika.kuromoji.example.TokenizerExample "
  input_json.each do |sen|
    sen = "\"#{sen}\" "
    command << sen
  end
  output = `#{command}`
  puts output

  # split by sentences
  sentences = output.split("sentence:\n")
  sentences = sentences[1..sentences.size]

  # process each sentences
  overall_json = []
  sentences.each do |sentence|
    tokens = sentence.split("\n")

    result_json = {}
    result_json["input"] = tokens[0]
    parsed_tokens = []
    tokens = tokens[1..tokens.size]
    tokens.each do |token|
      parsed_token = parse_token(token)
      parsed_tokens << parsed_token
    end

    result_json["tokens"] = parsed_tokens
    overall_json << result_json
  end

  json overall_json
end
