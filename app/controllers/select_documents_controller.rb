class SelectDocumentsController < ApplicationController
  def index
    @form = SelectDocumentsForm.new({})
  end

  def select_documents
    @form = SelectDocumentsForm.new(params['select_documents_form'] || {})
    if @form.valid?
      ANALYTICS_REPORTER.report(request, 'Select Documents Next')
      selected_evidence = @form.selected_evidence
      store_selected_evidence('documents', selected_evidence)
      if documents_eligibility_checker.any?(selected_evidence_values, available_idps)
        redirect_to select_phone_path
      else
        redirect_to unlikely_to_verify_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

  def unlikely_to_verify
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
  end

private

  def available_idps
    SESSION_PROXY.identity_providers(cookies)
  end

  def documents_eligibility_checker
    DOCUMENTS_ELIGIBILITY_CHECKER
  end
end
