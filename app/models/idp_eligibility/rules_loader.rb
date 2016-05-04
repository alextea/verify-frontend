require 'yaml'
require 'idp_eligibility/attribute_masker'
require 'idp_eligibility/evidence'

module IdpEligibility
  class RulesLoader
    attr_reader :recommended_rules
    attr_reader :non_recommended_rules
    def initialize(rules_path)
      @rules_path = rules_path
      @document_attribute_masker = AttributeMasker.new(Evidence::DOCUMENT_ATTRIBUTES)
    end

    def load
      recommended_rules = load_rules("recommended_rules")
      non_recommended_rules = load_rules("non_recommended_rules")
      all_rules = merge_rules(recommended_rules, non_recommended_rules)
      document_rules = apply_documents_mask(all_rules)
      GroupedRules.new(
        RulesRepository.new(recommended_rules),
        RulesRepository.new(non_recommended_rules),
        RulesRepository.new(all_rules),
        RulesRepository.new(document_rules)
      )
    end

    GroupedRules = Struct.new(:recommended_rules, :non_recommended_rules, :all_rules, :document_rules)

  private

    def apply_documents_mask(rules)
      @document_attribute_masker.mask(rules)
    end

    def load_rules(type)
      rules_files = File.join(@rules_path, '*.yml')
      Dir::glob(rules_files).inject({}) do |rules, file|
        yaml = YAML::load_file(file)
        idp_rules = yaml.fetch(type)
        yaml.fetch('simpleIds').each do |simple_id|
          rules[simple_id] = idp_rules.map { |rule| Profile.new(rule) }
        end
        rules
      end
    end

    def merge_rules(left_rules, right_rules)
      left_rules.merge(right_rules) do |_key, left, right|
        left + right
      end
    end
  end
end
