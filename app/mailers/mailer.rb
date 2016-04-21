class Mailer < ActionMailer::Base
  include BuildEmailAddressHelper
  helper FormattingHelper

  before_action { @include_subscription_preferences_link = true }

  layout 'base_mailer'

  def search_results(user, opportunity_ids)
    @user = user
    @opportunities = Opportunity.
                      where(id: opportunity_ids).
                      order_by_recently_posted

    mail(
      from: default_from_address,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.search_results.subject',
        site_title: Rails.configuration.x.site_title
      )
    )
  end

  def question_asked(user, question)
    @user = user
    @question = question

    mail(
      from: default_from_address,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.question_asked.subject',
        site_title: Rails.configuration.x.site_title
      )
    )
  end

  def question_answered(user, question)
    @user = user
    @question = question

    mail(
      from: default_from_address,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.question_answered.subject',
        site_title: Rails.configuration.x.site_title
      )
    )
  end

  def approval_request(user, opportunity)
    @user = user
    @opportunity = opportunity
    @creator = opportunity.created_by_user

    mail(
      from: default_from_address,
      reply_to: @creator.email,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.approval_request.subject',
        creator: @creator.name,
        site_title: Rails.configuration.x.site_title
      )
    )
  end

  def question_deadline(user, opportunity)
    @user = user
    @opportunity = opportunity

    mail(
      from: default_from_address,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.question_deadline.subject',
        opportunity: @opportunity.title
      )
    )
  end

  def submission_deadline(user, opportunity)
    @user = user
    @opportunity = opportunity

    mail(
      from: default_from_address,
      to: build_email_address(user.email, user.name),
      subject: t(
        'mailer.submission_deadline.subject',
        opportunity: @opportunity.title
      )
    )
  end

  private

  def default_from_address
    build_email_address(
      Rails.configuration.x.email_notification_from_address,
      Rails.configuration.x.site_title
    )
  end
end
