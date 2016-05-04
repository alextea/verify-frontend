require 'spec_helper'
require 'idp_eligibility/rules_repository'
require 'idp_eligibility/profiles_loader'
require 'idp_eligibility/profile'

module IdpEligibility
  describe ProfilesLoader do
    def fixtures(data = '')
      File.join('spec', 'fixtures', data)
    end

    describe '#load' do
      it 'should load recommended profiles from YAML files' do
        evidence = [Profile.new(%i(passport driving_licence))]
        profiles_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence
        )
        expect(ProfilesLoader.new(fixtures('good_profiles')).load.recommended_profiles).to eq(profiles_repository)
      end

      it 'should load non recommended profiles from YAML files' do
        evidence = [Profile.new(%i(passport mobile_phone))]
        profiles_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence
        )
        expect(ProfilesLoader.new(fixtures('good_profiles')).load.non_recommended_profiles).to eq(profiles_repository)
      end

      it 'should load all profiles from YAML files' do
        evidence = [Profile.new(%i{passport driving_licence}), Profile.new(%i(passport mobile_phone))]
        profiles_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence
        )
        expect(ProfilesLoader.new(fixtures('good_profiles')).load.all_profiles).to eq(profiles_repository)
      end

      it 'should supply a seperate repository of document profiles' do
        evidence = [Profile.new(%i{passport driving_licence}), Profile.new(%i(passport))]
        profiles_repository = RulesRepository.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence
        )
        expect(ProfilesLoader.new(fixtures('good_profiles')).load.document_profiles).to eq(profiles_repository)
      end

      it 'should raise an error when expected keys are missing from yaml' do
        expect {
          ProfilesLoader.new(fixtures('bad_profiles')).load
        }.to raise_error KeyError
      end

      it 'should return an empty object when no yaml files found' do
        expect(ProfilesLoader.new(fixtures).load.all_profiles).to eq(RulesRepository.new({}))
      end
    end
  end
end
