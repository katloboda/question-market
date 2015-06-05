class AnswersController < ApplicationController
  
  def create
    answer = Answer.new(params.require(:answer)
      .permit(:text))
    question = Question.find(params[:question_id])
    question.answers << answer
    question.save
    render json: question.to_json
  end

  # Authorization note: this method requires a 'user' node sent in the JSON request payload. The keys in that node
  #   should be role & id. It is assumed for the moment that the calling client (i.e. AskUp) is trusted, so we can
  #   use this information to determine whether someone should be able to update a given record.
  # (also see "Note" re: updated_at for questions_controller.update)
  def update
    # Answer does not currently have a user_id
    answer_params = params.require(:answer).permit(:text, :id)
    user_params = params.require(:user).permit(:id, :role)
    answer = Answer.find(params[:id])
    if user_params[:role] != 'admin' and answer.question.user_id != user_params[:id]
      msg = "user #{user_params[:id]} with role #{user_params[:role]} attempted to modify answer #{answer.id} "
      msg << "(belonging to question with user_id #{answer.question.user_id}) without permission"
      logger.debug msg
      render status: 403, json: {}
    end
    logger.debug "Updating answer: #{answer}"
    if answer.update(answer_params)
      logger.debug "Updated answer: #{answer}"
      render status: 200, json: answer
    else
      render status: 400, json: {}
    end
  end

end
