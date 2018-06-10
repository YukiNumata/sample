# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "csv"

#CSVで保存されたシラバス情報を読み込み

CSV.foreach('database_revised.csv') do |row|
  Lesson.create(idLesson: row[0], titleJapanese: row[1], titleEnglish: row[2], nameTeacherJapanese: row[3], nameTeacherEnglish: row[4], abstract: row[5], commonCode: row[6], semester: row[7], credits: row[8], tagakubu: row[9], classroomJapanese: row[10], classroomEnglish: row[11], language: row[12], schedule: row[13], method: row[14], evaluation: row[15], period: row[16], periodDay: row[17], periodTime: row[18], semesters: row[19],school_year: row[20])

end
