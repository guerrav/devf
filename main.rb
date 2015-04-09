require 'sinatra'
require 'slim'
require 'data_mapper'
require "sinatra/reloader" if development?
require 'sinatra/assetpack'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Event
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String
  property :capacity,     Integer
  property :date,         DateTime
  property :place,        String
  property :city,         String
  property :description,  String

  
  has n, :tickets
end

class Ticket
  include DataMapper::Resource
  property :id,           Serial
  property :price,        Integer 
  property :nametype,     String
  property :description,  String  
  property :capacity,     Integer 

  has n, :bookings
  belongs_to :event
end

class Booking
  include DataMapper::Resource
  property :id,           Serial 
  property :name,         String 
  property :lastname,     String 
  property :email,        String
  property :date,         DateTime
  property :amount,       Integer  

  belongs_to :ticket
  belongs_to :event
  has n, :payments
end
  
class Payment
  include DataMapper::Resource
  property :id,           Serial
  property :type,         String
  belongs_to :booking
end




DataMapper.finalize


get '/' do
  @events = Event.all(:order => [:name])
  slim :index
end

get '/new-event' do
  @events = Event.all(:order => [:name])
  slim :new_event
end

get '/event/new-booking/:id' do
  @event = Event.get(params[:id])
  slim :new_booking
end

get '/event/info/:id' do
  @event = Event.get(params[:id])
  slim :event_info
end

get '/booking/:id' do


  @booking = Booking.get(params[:id])
  slim :payment
end

get '/booking/payment/:id' do

  @payment = Payment.get(params[:id])
  slim :confirmation
end


get '/my-events' do

  @events = Event.all(:order => [:name])
  slim :my_events
end


######## EVENT

post '/new/event' do
  Event.create params['event']
  redirect back
end

delete '/event/:id' do
  Event.get(params[:id]).destroy
  redirect back
end


######## TICKET

# CREATE

post '/new-event/:id' do
  
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

#put '/ticket/:id' do
#  ticket = Ticket.get params[:id]
#  ticket.update(params[:ticket])  
#end



######## BOOKING

# CREATE

post '/ticket/:id' do
  ticket = Ticket.get(params[:id])
  booking = ticket.bookings.create! params['booking']
  booking.event_id = ticket[:event_id]
  booking.save

  redirect '/booking/' + booking.id.to_s
end



######## PAYMENT

# CREATE

post '/booking/:id' do
  booking = Booking.get(params[:id])
  payment = booking.payments.create! params['payment']
  payment.save
  redirect '/booking/payment/' + payment.id.to_s
end



post '/:id' do
  Event.get(params[:id]).tasks.create params['task']
  redirect '/'
end




