class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction_simple_id,
      request
    )
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers)
  end

  def choosing_a_company
  end

private

  def identity_providers
    SESSION_PROXY.identity_providers(cookies)
  end
end
