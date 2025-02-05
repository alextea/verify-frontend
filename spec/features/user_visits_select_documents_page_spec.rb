require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.feature 'When the user visits the select documents page' do
  before(:each) do
    set_session_cookies!
  end

  it 'displays the page in Welsh' do
    visit '/dewis-dogfennau'
    expect(page).to have_title 'Dewiswch yr holl ddogfennau sydd gennych'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes the appropriate feedback source' do
    visit '/select-documents'

    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE')
  end

  it 'redirects to the select phone page when user has a driving licence' do
    stub_federation
    visit '/select-documents'

    choose 'select_documents_form_driving_licence_true'
    click_button 'Continue'

    expect(page).to have_current_path(select_phone_path, only_path: true)
    expect(page.get_rack_session['selected_evidence']).to eql('documents' => %w{driving_licence})
  end

  it 'redirects to the select phone page when no docs checked' do
    stub_federation_no_docs
    visit '/select-documents'

    check I18n.translate('hub.select_documents.question.no_documents')
    click_button 'Continue'

    expect(page).to have_current_path(select_phone_path, only_path: true)
  end

  context 'without javascript', js: false do
    it 'will show an error message when no selections have been made' do
      visit 'select-documents'

      click_button 'Continue'

      expect(page).to have_css '.validation-message', text: 'Please select the documents you have'
      expect(page).to have_css '.form-group.error'
    end
  end

  it 'will redirect user to a unlikely to verify page when no eligible profiles match selected evidence' do
    page.set_rack_session(transaction_simple_id: 'test-rp')
    stub_federation
    visit 'select-documents'
    check 'select_documents_form_no_documents'

    click_button 'Continue'

    expect(page).to have_current_path(unlikely_to_verify_path)
  end

  it 'reports to Piwik when form is valid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    stub_federation_no_docs
    piwik_request = {
        'action_name' => 'Select Documents Next'
    }

    visit 'select-documents'
    check 'select_documents_form_no_documents'
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to Piwik when form is invalid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = {
        'action_name' => 'Select Documents Next'
    }

    visit 'select-documents'
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to_not have_been_made
  end

  context 'when redirecting to the select phone page' do
    it 'sets selected-evidence param to no-documents when no docs checked' do
      stub_federation_no_docs
      visit '/select-documents'

      check 'select_documents_form_no_documents'
      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path, only_path: true)
    end
  end
end
