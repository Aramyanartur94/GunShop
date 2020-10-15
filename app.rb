#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'Gun.db'
	@db.results_as_hash = true
	return @db
end

before do
	init_db
end

configure do
	@db = init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Knifes"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"nameknife"	TEXT,
		"description" TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Comments"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"comment"	TEXT,
		"post_id"	INTEGER
	)'
end

get '/' do
	@results = @db.execute 'select * from Knifes order by id desc'
	erb :index			
end

get '/add' do
  erb :add
end

get '/catalog' do
  "Hello World"
end

get '/details/:post_id' do
	post_id = params[:post_id]
	results = @db.execute 'select * from Knifes where id = ?', [post_id]
	@row = results[0]
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
	erb :details

end

post '/add' do
	nameknife = params[:nameknife]
	if nameknife.length <= 0
		@error = 'Название товара'
		return erb :add
	end
		
	description = params[:description]
	if description.length <= 0
		@error = 'Введите описание товара'
		return erb :add
	end
	@db.execute 'Insert into Knifes (nameknife, created_date, description) values (?, datetime(), ?)', [nameknife, description]
	redirect to '/'
end

post '/details/:post_id' do
	post_id = params[:post_id]
	comment = params[:comment]
	@db.execute 'Insert into Comments (created_date, comment, post_id) values (datetime(), ?, ?)', [comment, post_id]
	redirect to ('/details/' + post_id)

end