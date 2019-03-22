# frozen_string_literal: true

class ExpertMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/expert_mailer'

  def notify_company_needs(person, diagnosis)
    @person = person
    if person.is_a? Expert
      @access_token = person.access_token
    end
    @diagnosis = diagnosis

    mail(
      to: @person.email_with_display_name,
      cc: @diagnosis.advisor.email_with_display_name,
      subject: t('mailers.expert_mailer.notify_company_needs.subject', company_name: @diagnosis.company.name),
      reply_to: [
        SENDER,
        @diagnosis.advisor.email_with_display_name
      ]
    )
  end

  def remind_involvement(person, matches_taken_not_done, matches_quo_not_taken)
    @person = person
    if person.is_a? Expert
      @access_token = person.access_token
    end
    @matches_taken_not_done = matches_taken_not_done
    @matches_quo_not_taken = matches_quo_not_taken

    mail(
      to: @person.email_with_display_name,
      subject: t('mailers.expert_mailer.remind_involvement.subject')
    )
  end
end
