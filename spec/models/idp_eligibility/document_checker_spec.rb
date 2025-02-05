require 'spec_helper'
require 'models/idp_eligibility/evidence'
require 'models/idp_eligibility/checker'
require 'models/idp_eligibility/masking_rules_repository'
require 'models/idp_eligibility/document_checker'
require 'set'

module IdpEligibility
  RSpec.describe DocumentChecker do
    let(:rules_repository) { double(:rules_repository) }
    let(:checker) { DocumentChecker.new(rules_repository) }
    let(:singleton_idp) { [double(:idp, simple_id: 'idp')] }

    context '#any?' do
      it 'should return false when no idp rules are set up' do
        allow(rules_repository).to receive(:rules).and_return({})
        user_docs = [:passport]
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should return false when user has no documents matching rules' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:driving_licence]])
        user_docs = []
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should return true when user has evidence accepted by an idp' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:driving_licence]])
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should return true when user has no docs and idp accepts no docs' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[]])
        user_docs = []
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should return false when user has a document that does not match rules' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:driving_licence]])
        user_docs = [:passport]
        expect(checker.any?(user_docs, singleton_idp)).to be_falsey
      end

      it 'should ignore non document stage requirements' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[:hat, :driving_licence]])
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, singleton_idp)).to be_truthy
      end

      it 'should work when no idps are provided' do
        allow(rules_repository).to receive(:rules).and_return('idp' => [[]])
        user_docs = [:driving_licence]
        expect(checker.any?(user_docs, [])).to be_falsey
      end
    end
  end
end
