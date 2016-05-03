require 'spec_helper'
require 'models/idp_eligibility/masking_rules_repository'

module IdpEligibility
  RSpec.describe MaskingRulesRepository do
    it 'applies a mask of whitelisted attributes to every rule contained within an exisiting repository' do
      mask = %w{passport driving_licence}
      unmasked = {
        'idp_one' => [%w{passport mobile_phone}, %w{driving_licence landline}, %w{mobile_phone landline}],
        'idp_two' => [%w{passport driving_licence}, %w{mobile_phone smart_phone}]
      }
      expected = {
        'idp_one' => [%w{passport}, %w{driving_licence}, []],
        'idp_two' => [%w{passport driving_licence}, []]
      }
      expect(MaskingRulesRepository.new(mask).mask(unmasked)).to eql expected
    end
  end
end
