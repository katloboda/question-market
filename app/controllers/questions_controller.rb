class QuestionsController < ApplicationController
  def index
    render json: Question.all, :include => :answers
  end

  def create
    logger.debug "PARAMS for create: #{params}"
    question = Question.new(params.require(:question).permit(:text, :user_id))
    logger.debug "QUESTION created: #{question}"
    logger.debug "ID of Question created: #{question.id}"
    params[:answers].each do |a|
      question.answers << Answer.new(a.permit(:text))
    end
    question.save
    # Does this need .to_json() if it is called as render json: ?
    render json: question.to_json(:include => :answers)
  end


  def destroy
    logger.debug "PARAMS for destroy: #{params}"
    @question = Question.find(params[:id])
    logger.debug "QUESTION for destroy: #{@question}"
    @question.destroy

  end

end
