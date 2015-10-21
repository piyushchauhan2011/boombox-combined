# Embedded Artist Tags Model
class ArtistTag
  include Mongoid::Document
  field :tagID, type: Integer
  field :tag_value, type: String
  field :timestamp, type: Date

  index 'tagID' => 1
  embedded_in :all_artist
end
