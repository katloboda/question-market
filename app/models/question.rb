class Question < ActiveRecord::Base
  has_many :answers
  accepts_nested_attributes_for :answers

  def to_s
    self.to_json(:include => :answers)
  end
end
