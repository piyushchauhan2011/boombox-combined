# User Recommendation Relationship
# class UserRecommendation
#   include Neo4j::ActiveRel

#   from_class User
#   to_class Artist
#   type 'user_recommendation'

#   property :sum_artist_weight, type: Integer, default: 0
#   property :total_listeners_count, type: Integer, default: 0
# end
# User Recommendations Model
class UserRecommendation
  include Mongoid::Document
  field :artistID, type: Integer
  field :sum_artist_weight, type: Integer, default: 0
  field :total_listeners_count, type: Integer, default: 0

  index 'artistID' => 1
  embedded_in :user_doc
end
