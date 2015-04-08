require 'sinatra'
require 'slim'
require 'data_mapper'
require "sinatra/reloader" if development?

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Event
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String
  property :capacity,     Integer
  property :date,         DateTime
  property :place,        String
  property :description,  String

  has n, :reservations
  has n, :tickets
end

class Reservation
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String 
  property :lastname,     String 
  property :email,        String
  property :date,         DateTime
  property :amount,       Integer  

  belongs_to :ticket
  belongs_to :event
end
  
class Ticket
  include DataMapper::Resource
  property :id,           Serial
  property :price,        Integer 
  property :nametype,     String
  property :description,  String  
  property :capacity,     Integer 

  
  belongs_to :event
end




class Payment
  include DataMapper::Resource
  property :id,           Serial
  property :type,         String
  belongs_to :reservation
end




DataMapper.finalize


get '/' do
  @events = Event.all(:order => [:name])
  slim :index
end





######## EVENT

post '/new/event' do
  Event.create params['event']
  redirect '/'
end

delete '/event/:id' do
  Event.get(params[:id]).destroy
  redirect back
end


######## TICKET

# CREATE

post '/event/:id' do
  
  event = Event.get(params[:id])
  ticket = event.tickets.create! params['ticket']
  ticket.save
  redirect back
end

# DELETE

delete '/ticket/:id' do
  Ticket.get(params[:id]).destroy
  redirect back
end

# UPDATE

put '/ticket/:id' do
  ticket = Ticket.get params[:id]
  ticket.update(params[:ticket])  
end





post '/:id' do
  Event.get(params[:id]).tasks.create params['task']
  redirect '/'
end




