class QuestionsController < ApplicationController
  def index
    render json: Question.all, :include => :answers
  end

  def show
    render json: Question.find(params[:id]), :include => :answers
  end

  def create
    question = Question.new(params.require(:question).permit(:text, :user_id))
    params[:answers].each do |a|
      question.answers << Answer.new(a.permit(:text))
    end
    question.save
    logger.debug "QUESTION created: #{question}"
    logger.debug "ID of Question created: #{question.id}"
    render json: question.to_json(:include => :answers)
  end

  # Authorization note: this method requires a 'user' node sent in the JSON request payload. The keys in that node
  #   should be role & id. It is assumed for the moment that the calling client (i.e. AskUp) is trusted, so we can
  #   use this information to determine whether someone should be able to update a given record.
  # Note: when question or answer is modified (updated_at changes), the other one doesn't necessarily get modified.
  #   This could be ameliorated by using PUT instead of PATCH, or possibly on the frontend checking the newer of those
  #   two values and using that in the UI to show last time that set of things changed.
  def update
    question_params = params.require(:question).permit(:text, :id)
    user_params = params.require(:user).permit(:id, :role)
    question = Question.find(params[:id])
    # authorization
    if user_params[:role] != 'admin' and question.user_id != user_params[:id]
      msg = "user #{user_params[:id]} with role #{user_params[:role]} attempted to modify question #{question.id} "
      msg << "(with user_id #{question.user_id}) without permission"
      logger.debug msg
      render status: 403, json: {} and return
    end
    logger.debug "Updating question: #{question}"
    if question.update(question_params)
      logger.debug "Updated question: #{question}"
      render status: 200, json: question.to_json(:include => :answers)
    else
      render status: 400, json: {}
    end
  end

  def destroy
    question = Question.find(params[:id])
    logger.debug "QUESTION for destroy: #{question}"
    question.destroy
    render status: 200, json: {}
  end

end
