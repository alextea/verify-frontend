class ChooseACertifiedCompanyController < ApplicationController
  protect_from_forgery except: :select_idp

  def index
    grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, identity_providers)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.recommended)
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(grouped_identity_providers.non_recommended)
  end

  def select_idp
    session[:selected_idp] = IdentityProvider.new(params.fetch('identity_provider'))
    session[:selected_idp_was_recommended] = params.fetch('recommended-idp') == 'true'
    redirect_to redirect_to_idp_warning_path
  end

  def about
    simple_id = params[:company]
    matching_idp = identity_providers.detect { |idp| idp.simple_id == simple_id }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if @idp.viewable?
      grouped_identity_providers = IDP_ELIGIBILITY_CHECKER.group_by_recommendation(selected_evidence_values, [@idp])
      @recommended = grouped_identity_providers.recommended.any?
      render 'about'
    else
      render 'errors/404', status: 404
    end
  end

private

  def identity_providers
    SESSION_PROXY.identity_providers(cookies)
  end
end
