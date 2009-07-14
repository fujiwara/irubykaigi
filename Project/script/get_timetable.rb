require 'rubygems'
require 'mechanize'
require 'open-uri'
require File.expand_path(File.dirname(__FILE__) + '/simple-json')

@base_dir = File.expand_path(File.dirname(__FILE__))
@store_dir = @base_dir + "/.."


@keys = %w(code date time title speaker break room floor attention abstract profile)
@sessions = []
@rooms = []
@titles = Hash.new

def add_room room
  @rooms.each do |r|
    if r[0, room.size] == room
      return r
    end
  end
  if room == 'Hitotsubashi Memorial Hall'
    room = 'Hitotsubashi Memorial Hall(2nd Floor)'
  end
  /(.*)\((.*)\)/ =~ room
  @rooms << [$1, $2]
  room
end

def normalized_room room
  r = @rooms.find {|e| e[0] == room}
  if r
    r
  else
    /(.*)\s*\((.*)\)/ =~ room
    [$1, $2]
  end
end


def room_for_index i
  @rooms[i]
end

def room_for_session session
  codes = %w(H M S)
  /(H|M|S)/ =~ session['code']
  if $1
    room_for_index codes.index($1)
  else
    [nil, nil]
  end
end



def parse_timetable elements, day, json_url
  code_dict = Hash.new

  # 部屋情報
  elements.search('th.room').map {|e| add_room(e.inner_text)}
  
  elements.search('tbody tr').each do |session_info|
    
    # 時間帯
    time = session_info.search('th').first.inner_text
    
    # session情報の取得
    session_info.search('div.session').each_with_index do |e, index|
    
      session = Hash.new
      session['metadata'] = e
      title = e.search('p.title').first
      if title
        session['title'] = title.inner_text
        link = title.search('a').first
        if link
          session['href'] = 'http://rubykaigi.org' << link[:href] 
          session['code'] = link[:href].split("/").last
          code_dict[session['code']] = session
        end
      end
      speaker = e.search('p.speaker').first
      session['speaker'] = speaker.inner_text.gsub('（', '(').gsub('）', ')').strip if speaker
      session['room'], session['floor'] = room_for_index(index)
      session['time'] = time
      session['date'] = day
      @sessions << session
    end

    # breakの情報
    session_info.search('td.break').each do |e|
      session = Hash.new
      session['title'] = e.inner_text
      session['time'] = time
      session['date'] = day
      session['room'] = nil
      session['floor'] = nil
      session['break'] = true
      @sessions << session
    end
  end

  # 詳細情報の取得
  # セッション情報の取得
  # 大部分はjsonから得る
  src = ''
  open(json_url) do |f|
    src = f.read
  end
  json = WebAPI::JsonParser.new.parse(src)
 
  json.each do |item|
    talk = item['talk']
    if talk['code']
      session = code_dict[talk['code']]
      if session
        session['title'] = talk['title']
        session['speaker'] = talk['speaker'].gsub('（', '(').gsub('）', ')').strip
        session['abstract'] = talk['abstract'].gsub("\n", ' ').strip if talk['abstract']
        session['profile'] = talk['profile'].gsub("\n", ' ').strip if talk['abstract']
        session['room'], session['floor'] = room_for_session session
      end
    end
  end
  
  # 例外
  session = @sessions.find{|e| e['title'] == 'Beer bust'}
  session['room'], session['floor'] = room_for_index(1) if session
  
  session = @sessions.find{|e| e['title'] == 'Closing'}
  session['room'], session['floor'] = room_for_index(0) if session
  
  # 注意事項(attentionに含める)
  session = @sessions.find{|e| e['speaker'] == '(この部屋の開始時刻は10:00です)' || e['speaker'] == '(this room will start at 10:00)'}
  if session
    session['room'], session['floor'] = room_for_index(2)
    session['attention'] = session['speaker']
    session['speaker'] = nil
  end
  
   
end

def get_parse_store_and_love uri, filename, json_url
  @sessions = []
  @rooms = []
  
  # セッション情報の取得
  agent = WWW::Mechanize.new
  agent.get(uri)
  page = agent.page
  
  # 解析
  days = page.search('h2').map {|e| e.inner_text.gsub(/年|月/, '-').gsub(/日.*/, '')}
  page.search('table.timetable').each_with_index do |timetable, i|
    parse_timetable timetable, Date.parse(days[i]), json_url
  end

  # ファイルのデータに整形
  lines = []
  @sessions.each do |s|
    a = []
    @keys.each do |key|
      a << s[key] ? s[key] : ''
    end
    lines << a.join("\t")
  end

  # ファイルに保存
  File.open(filename, 'w') do |f|
    f.puts @keys.join("\t")
    lines.each do |l|
      f.puts l
    end
  end
end


get_parse_store_and_love 'http://rubykaigi.org/2009/ja/talks', @store_dir + '/Japanese.lproj/session_info.csv', 'http://rubykaigi.org/2009/ja/talks.json'
get_parse_store_and_love 'http://rubykaigi.org/2009/en/talks', @store_dir + '/English.lproj/session_info.csv', 'http://rubykaigi.org/2009/en/talks.json'

