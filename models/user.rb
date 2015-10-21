# User Neo4j Model
class User
  include Neo4j::ActiveNode

  property :userID, type: Integer, index: :exact

  has_many :both, :friends, type: :friends, model_class: :User
  has_many :out, :artists, rel_class: :ListenTo
  has_one :out, :user_recommendation, rel_class: :UserRecommendation

  def generate_recommendation
    tmp = artists.map(&:artistID).to_a
    ud = UserDoc.find_or_create_by(userID: userID)
    friends.each do |f|
      ids = f.artists.map(&:artistID) - tmp
      f.artists.where(artistID: ids).each_with_rel do |a, r|
        ur = ud.user_recommendations.find_or_create_by(artistID: a.artistID)
        ur.sum_artist_weight += r.weight
        ur.total_listeners_count += 1
        ur.save
      end
    end
  end
end
