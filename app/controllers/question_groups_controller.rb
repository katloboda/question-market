class QuestionGroupsController < ApplicationController
  def index
    render json: QuestionGroup.all
  end

  def show
    render json: QuestionGroup.find(params[:id])
  end

  def create
    question_group = QuestionGroup.new(params.require(:question_group).permit(:name, :parent_id))
    question_group.save
    logger.debug "QuestionGroup created: #{question_group}"
    render json: question_group.to_json
  end

  def update
    question_group_params = params.require(:question_group).permit(:name, :parent_id)
    question_group = QuestionGroup.find(params[:id])
    logger.debug "Updating QuestionGroup: #{question_group}"
    if question_group.update(question_group_params)
      logger.debug "Updated QuestionGroup: #{question_group}"
      render status: 200, json: question_group.to_json
    else
      render status: 400, json: {}
    end
  end

  # Delete question group and move all its questions into the parent group
  def destroy
    qg_id = params[:id]
    question_group = QuestionGroup.find(qg_id)
    qg_parent_id = question_group.parent_id
    # prevent deletion of root question group or parent-less group
    if qg_id != 1 and !qg_parent_id.nil? and question_group.destroy
      orphan_questions = Question.where('question_group_id = ?', qg_id)
      orphan_questions.update_all(question_group_id: qg_parent_id)
      render status: 200, json: {}
    else
      render status: 400, json: {}
    end
  end
end
