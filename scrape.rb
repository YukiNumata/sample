
#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

#webに接続するためのライブラリ
require "open-uri"
#クレイピングに使用するライブラリ
require "nokogiri"

require "json"
require "csv"
#クレイピング対象のURL



3.times do |i|
  j = i + 40001
  url = "http://catalog.he.u-tokyo.ac.jp/jd-detail?code=" + j.to_s + "&year=2018"
  #取得するhtml用charset
  charset = nil

  html = open(url) do |page|
    #charsetを自動で読み込み、取得
    charset = page.charset
    #中身を読む
    page.read
  end


  # 初期値の設定
  titleJapanese = "-"
  titleEnglish = "-"
  nameTeacherEnglish = "-"
  nameTeacherJapanese = "-"
  abstract = "-"
  commonCode = "-"
  semester = "-"
  credits = "-"
  tagakubu = "-"
  classroomJapanese = "-"
  classroomEnglish = "-"
  language = "-"
  schedule = "-"
  method = "-"
  evaluation = "-"



  # Nokogiri で切り分け
  contents = Nokogiri::HTML.parse(html,nil,charset)
  # 教科名
  titleJapanese = contents.search(".detail-title:first-of-type span").text
  titleEnglish = contents.search(".detail-title:last-of-type span").text



  # id
  idLesson = j
  # 教員名の抽出処理
  nameTeacherJapanese = contents.xpath("//h2[@class='detail-title' and position()=1]").to_s
  nameTeacherJapanese.gsub!(/(\s|　)+/, '')
  nameTeacherJapanese.slice!(/<h2.*<\/span>/)
  nameTeacherJapanese.slice!(/<\/h2>/)
  nameTeacherEnglish = contents.xpath("//h2[@class='detail-title' and position()=2]").to_s
  nameTeacherEnglish.gsub!(/(\s|　)+/, '')
  nameTeacherEnglish.slice!(/<h2.*<\/span>/)
  nameTeacherEnglish.slice!(/<\/h2>/)
  # abstract
  abstract = contents.xpath("/html/body[@class='jd']/div[@id='container']/div[@id='screen']/div[@id='pagebody']/div[@id='contents']/div[@class='detail-text white-space-pre-wrap'][1]").text

  # commonCode
  commonCode = contents.search("table.detail tr:first-of-type td:first-of-type").text.gsub!(/(\s|　)+/, '')

  #開講時間
  period = contents.xpath("//table[@class='detail']").text.gsub!(/(\s|　)+/, '')

  #存在しない場合はスキップ
  next if period == nil

  period = period.slice!(/Period(.*?)単位数/)
  period = period.gsub!("Period","")
  period = period.gsub!("単位数","")

  if period.include?("月")
    periodDay = 1
  elsif period.include?("火")
    periodDay = 2
  elsif period.include?("水")
    periodDay = 3
  elsif period.include?("木")
    periodDay = 4
  elsif period.include?("金")
    periodDay = 5
  else
    periodDay = period
  end

  if period.include?("1")
    periodTime = 1
  elsif period.include?("2")
    periodTime = 2
  elsif period.include?("3")
    periodTime = 3
  elsif period.include?("4")
    periodTime = 4
  elsif period.include?("5")
    periodTime = 5
  elsif period.include?("6")
    periodTime = 6
  else
    periodTime = period
  end

  # semester
  semester = contents.search("table.detail tr:nth-of-type(2) td:first-of-type").text.gsub!(/(\s|　)+/, '')


  if semester.include?("S1") && semester.include?("S2")
    semesters = ["S1","S2"]
  elsif semester.include?("S1")
    semesters = ["S1"]
  elsif semester.include?("S2")
    semesters = ["S2"]
  else
    semesters = semester
  end


  # credits
  credits = contents.search("table.detail tr:nth-of-type(4)").text.gsub!(/(\s|　)+/, '')
  credits = credits.gsub(/[^\d]/, "").to_i
  #tagakubu
  tagakubu = contents.search("table.detail tr:nth-of-type(6) td").text.gsub!(/(\s|　)+/, '')
  if tagakubu.include?("NO")
    tagakubu = false
  else
    tagakubu = true
  end
  #classroom
  classroomJapanese = contents.search("table.detail tr:nth-of-type(7) td div:first-of-type").text.gsub!(/(\s|　)+/, '')
  classroomEnglish = contents.search("table.detail tr:nth-of-type(7) td div:nth-of-type(2)").text.gsub!(/(\s|　)+/, '')
  #language
  language = contents.search("table.detail tr:nth-of-type(8) td").text.gsub!(/(\s|　)+/, '')
  #schedule
  schedule = contents.search("table.detail tr:nth-of-type(10) td").text
  #method
  method = contents.search("table.detail tr:nth-of-type(11) td").text
  #evaluation
  evaluation = contents.search("table.detail tr:nth-of-type(12) td").text

  school_year = 2018

  puts "\nid:" + idLesson.to_s
  puts "授業名(日本語):\t" + titleJapanese
  puts "授業名(英語):\t" + titleEnglish
  puts "教員名(日本語):\t" + nameTeacherJapanese
  puts "教員名(英語):\t" + nameTeacherEnglish
  puts "概要:\t" + abstract
  puts "共通科目コード:\t" + commonCode
  puts "開講時期:\t" + semester
  puts "単位数:\t" + credits.to_s
  puts "他学部聴講:\t" + tagakubu.to_s
  # puts "教室(日本語):\t" + classroomJapanese
  # puts "教室(英語):\t" + classroomEnglish
  # puts "使用言語:\t" + language
  # puts "授業計画:\t" + schedule
  # puts "授業の方法:\t" + method
  # puts "成績評価:\t" + evaluation
  # puts "授業時間:\t" + period
  # puts "授業曜日:\t" + periodDay
  # puts "授業時限:\t" + periodTime.to_s
  puts "セメスター:\t" +
  semesters

  # f = File.open("database.json",'a+') do |file|
  #   hash = {
  #     "id" => idLesson.to_s,
  #     "titleJapanese" => titleJapanese,
  #     "titleEnglish" => titleEnglish,
  #     "nameTeacherJapanese" => nameTeacherJapanese,
  #     "nameTeacherEnglish" => nameTeacherEnglish,
  #     "abstract" => abstract,
  #     "commonCode" => commonCode,
  #     "semester" => semester,
  #     "credits" => credits,
  #     "tagakubu" => tagakubu,
  #     "classroomJapanese" => classroomJapanese,
  #     "classroomEnglish" => classroomEnglish,
  #     "language" => language,
  #     "schedule" => schedule,
  #     "method"=> method,
  #     "evaluation" => evaluation
  #   }
  #     str = JSON.dump(hash, file)
  # end

  CSV.open("database_test.csv", "a+") do |file|
    file << [idLesson, titleJapanese, titleEnglish, nameTeacherJapanese, nameTeacherEnglish, abstract, commonCode, semester, credits, tagakubu, classroomJapanese, classroomEnglish, language, schedule, method, evaluation, period, periodDay, periodTime, semesters.to_s, school_year]
  end




  #idを一つずつすすめる
  i += 1
  #DDos攻撃回避のためにインターバル
  sleep(0.4)

end
