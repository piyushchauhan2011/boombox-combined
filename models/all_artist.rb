# Artist Mongoid Model
class AllArtist
  include Mongoid::Document

  field :artistID, type: Integer
  field :name, type: String
  field :url, type: String
  field :picture_url, type: String

  embeds_many :artist_tags

  field :sum_artist_weight, type: Integer, default: 0
  field :total_listeners_count, type: Integer, default: 0

  index 'artistID' => 1
  index 'name' => 1

  def self.generate_recommendation
    User.all.each do |u|
      u.artists.each_with_rel do |a, r|
        ta = AllArtist.find_by(artistID: a.artistID)
        ta.sum_artist_weight += r.weight
        ta.total_listeners_count += 1
        ta.save
      end
    end
  end

  # Answers
  # 1. AllArtist.all.desc(:sum_artist_weight).take(5)
  # 2. AllArtist.all.desc(:total_listeners_count).take(5)
  # 3. AllArtist.where('artist_tags.tagID' => tag.tagID).desc(:sum_artist_weight).take(5)
end
