class AnswersController < ApplicationController
  
  def create
    answer = Answer.new(params.require(:answer)
      .permit(:text))
    question = Question.find(params[:question_id])
    question.answers << answer
    question.save
    render json: question.to_json
  end

end
