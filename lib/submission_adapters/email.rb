module SubmissionAdapters
  class Email < SubmissionAdapters::Base
    self.select_text = 'Email'

    def submit_proposals_instructions

      if @opportunity.contact_email == "admin@openvendorphilly.com"
        %(
          <a href='#{original_opportunity_url}' target='blank'>Click here for more information</a>.
        ).squish.html_safe
      else
        %(
          Proposals for this opportunity should be sent by email to
          <a href='mailto:#{submit_to_email}'>#{submit_to_name}</a>.
        ).squish.html_safe
      end
    end

    def valid?
      submit_to_email.present? &&
      submit_to_name.present?
    end

    private

    def submit_to_email
      @opportunity.submission_adapter_data['email']
    end

    def submit_to_name
      @opportunity.submission_adapter_data['name']
    end

    def original_opportunity_url
      @opportunity.original_url
    end
  end
end
