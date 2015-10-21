# Artist Neo4j Model
class Artist
  include Neo4j::ActiveNode

  property :artistID, type: Integer, index: :exact

  has_many :in, :users, rel_class: :ListenTo
  has_one :in, :user_recommendation, rel_class: :UserRecommendation
end
