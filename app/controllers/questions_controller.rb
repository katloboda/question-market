class QuestionsController < ApplicationController
  def index
    render json: Question.all, :include => :answers
  end

  def create
    question = Question.new(params.require(:question).permit(:text, :user_id))
    params[:answers].each do |a|
      question.answers << Answer.new(a.permit(:text))
    end
    question.save
    # Does this need .to_json() if it is called as render json: ?
    render json: question.to_json(:include => :answers)
  end

end
