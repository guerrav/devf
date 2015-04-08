require 'sinatra'
require 'slim'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Event
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String
  property :capacity,     Integer

  has n, :purchases
  has n, :tickets
end
  
class Ticket
  include DataMapper::Resource
  property :id,           Serial
  property :price,       Integer ## 300
  property :name,         String ## premium
  property :capacity,       Integer ## 300


  has n, :purchases
  belongs_to :event
end

class Purchase
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String ## jorge
  property :lastname,         String ## castro
  property :email,         String ## ja@a.com

  has n, :items
  belongs_to :event
end


class Item
  include DataMapper::Resource
  property :id,           Serial 
  property :amount,         Integer

  belongs_to :purchase
  belongs_to :ticket
end


class Payment
  include DataMapper::Resource
  property :id,           Serial
  property :type,         String
  belongs_to :purchase
end




DataMapper.finalize


get '/' do
  @events = Event.all(:order => [:name])
  slim :index
end









post '/:id' do
  List.get(params[:id]).tasks.create params['task']
  redirect '/'
end

delete '/task/:id' do
  Task.get(params[:id]).destroy
  redirect '/'
end

put '/task/:id' do
  task = Task.get params[:id]
  task.completed_at = task.completed_at.nil? ? Time.now : nil
  task.save
  redirect '/'
end

post '/new/event' do
  Event.create params['event']
  redirect '/'
end

delete '/list/:id' do
  List.get(params[:id]).destroy
  redirect '/'
end
