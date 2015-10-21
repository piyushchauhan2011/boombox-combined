require 'bundler'
Bundler.setup
require 'sinatra'
require 'json'
require 'neo4j'
require 'mongoid'

Neo4j::Session.open(:server_db, 'http://localhost:7474/')
Neo4j::Config[:include_root_in_json] = false

Mongoid.load!('./mongoid.yml', :development)

require './models/user'
require './models/artist'
require './models/listen_to'
require './models/all_tag'
require './models/all_artist'
require './models/artist_tag'
require './models/user_doc'
require './models/user_recommendation'

get '/tags/index' do
  content_type :json
  AllTag.all.to_json
end

get '/tags/byID/:tag_id' do
  content_type :json
  AllTag.find_by(tagID: params[:tag_id]).to_json
end

get '/artists/index' do
  content_type :json
  AllArtist.all.limit(50).to_json
end

get '/artists/byName/:artist_name' do
  content_type :json
  AllArtist.where(name: /#{params[:artist_name]}/i).to_json
end

get '/artists/top_5_by_sum' do
  content_type :json
  AllArtist.all.desc(:sum_artist_weight).take(5).to_json
end

get '/artists/top_5_by_number' do
  content_type :json
  AllArtist.all.desc(:total_listeners_count).take(5).to_json
end

get '/artists/top_5_by_tags/:tag_id' do
  content_type :json
  AllArtist.where('artist_tags.tagID' => params[:tag_id].to_i).desc(:sum_artist_weight).take(5).to_json
end

get '/artists/byID/:id' do
  content_type :json
  AllArtist.find_by(artistID: params[:id].to_i).to_json
end

get '/artists/:id' do
  content_type :json
  AllArtist.find(params[:id]).to_json
end

get '/users/index' do
  content_type :json
  User.all.limit(50).to_json
end

get '/users/byID/:id' do
  content_type :json
  u = User.find_by(userID: params[:id].to_i)
  result = {
    _id: {
      '$oid': u.id
    },
    id: u.id,
    userID: u.userID,
    artists: u.artists,
    friends: u.friends
  }
  result.to_json
end

get '/users/:id/artists/:artist_id' do
  content_type :json
  u = User.find(params[:id])
  a = u.artists.where(artistID: params[:artist_id].to_i)
  result = {}
  a.each_with_rel do |n, r|
    result = {
      _id: {
        '$oid': n.id
      },
      id: n.id,
      artistID: n.artistID,
      weight: r.weight
    }
  end
  result.to_json
end

put '/users/:id/artists/:artist_id/listen' do
  content_type :json
  u = User.find(params[:id])
  a = u.artists.where(artistID: params[:artist_id].to_i)
  result = {}
  if (a.to_a != [])
    a.each_with_rel do |n, r|
      r.weight += 1
      r.save
      result = {
        _id: {
          '$oid': n.id
        },
        id: n.id,
        artistID: n.artistID,
        weight: r.weight
      }
    end
  else
    tmp_a = Artist.find_by(artistID: params[:artist_id].to_i)
    ListenTo.create(from_node: u, to_node: tmp_a, weight: 1)
    u.artists.where(artistID: params[:artist_id].to_i).each_with_rel do |n, r|
      result = {
        _id: {
          '$oid': n.id
        },
        id: n.id,
        artistID: n.artistID,
        weight: r.weight
      }
    end
  end
  result.to_json
end

put '/users/:id/add_friend/:user_id' do
  content_type :json
  u1 = User.find(params[:id])
  u2 = User.find_by(userID: params[:user_id].to_i)
  u1.friends << u2
  u1.save
  result = {
    _id: {
      '$oid': u1.id
    },
    id: u1.id,
    userID: u1.userID,
    artists: u1.artists,
    friends: u1.friends
  }
  result.to_json
end

put '/users/:id/artists/:artist_id/assign_tag/:tag_id' do
  content_type :json
  a = AllArtist.find_by(artistID: params[:artist_id])
  t = AllTag.find_by(tagID: params[:tag_id])
  tag = a.artist_tags.find_or_create_by(tagID: t.tagID)
  tag.tag_value = t.tag_value
  tag.timestamp = Date.today
  tag.save
  a.to_json
end

get '/users/:id/top_5_by_sum' do
  content_type :json
  u = User.find(params[:id])
  ud = UserDoc.find_by(userID: u.userID)
  ud.user_recommendations.desc(:sum_artist_weight).take(5).to_json
end

get '/users/:id/top_5_by_number' do
  content_type :json
  u = User.find(params[:id])
  ud = UserDoc.find_by(userID: u.userID)
  ud.user_recommendations.desc(:total_listeners_count).take(5).to_json
end

get '/users/:id/top_5_by_tags/:tag_id' do
  content_type :json
  u = User.find(params[:id])
  rt = AllTag.find_by(tagID: params[:tag_id])
  AllArtist.where('artist_tags.tagID' => rt.tagID).not_in(artistID: u.artists.map(&:artistID).to_a).desc(:total_listeners_count).take(5).to_json
end

get '/users/:id' do
  content_type :json
  u = User.find(params[:id])
  result = {
    _id: {
      '$oid': u.id
    },
    id: u.id,
    userID: u.userID,
    artists: u.artists,
    friends: u.friends
  }
  result.to_json
end
