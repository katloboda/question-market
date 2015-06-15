class QuestionGroup < ActiveRecord::Base
  has_many :questions
  validates_presence_of :name
  acts_as_tree order: :name

  def to_s
    self.to_json
  end
end
