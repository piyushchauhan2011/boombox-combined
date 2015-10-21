# User Model
class UserDoc
  include Mongoid::Document
  field :userID, type: Integer

  embeds_many :user_recommendations

  index 'userID' => 1

  # Answers
  # 1. u.user_recommendations.desc(:sum_artist_weight).take(5)
  # 2. u.user_recommendations.desc(:total_listeners_count).take(5)
  # 3. AllArtist.where('artist_tags.tagID' => rt.tagID).not_in(artistID: u.artists.map(&:artistID).to_a).desc(:total_listeners_count).take(5)
end
