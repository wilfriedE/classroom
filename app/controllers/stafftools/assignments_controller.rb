# frozen_string_literal: true

module Stafftools
  class AssignmentsController < StafftoolsController
    before_action :set_assignment

    def show; end

    def update_creator
      if @assignment.update_creator User.find(params[:user_id])
        flash[:success] = 'Assignment creator was updated'
      else
        flash[:error] = 'Could not update assignment creator'
      end
      redirect_to stafftools_assignment_path(@assignment.id)
    end

    private

    def set_assignment
      @assignment = Assignment.find_by!(id: params[:id])
    end
  end
end
