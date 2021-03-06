# frozen_string_literal: true

class UserMailer < ApplicationMailer
  SENDER = "#{I18n.t('app_name')} <#{SENDER_EMAIL}>"
  default from: SENDER, template_path: 'mailers/user_mailer'
  helper :institutions
  helper :status

  def match_feedback(feedback, person)
    @person = person
    return if @person.deleted?

    @feedback = feedback
    @author = feedback.user
    @match = person.received_matches.find_by(need: feedback.need.id)

    mail(to: @person.email_with_display_name,
         subject: t('mailers.user_mailer.match_feedback.subject', company_name: feedback.need.company))
  end

  def notify_match_status(match, previous_status)
    @match = match
    @advisor = match.advisor
    return if (@advisor.deleted? || @advisor.is_admin)

    @status = {}
    @expert = match.expert
    @previous_status = previous_status
    @company = match.company
    @need = match.need
    @subject = match.subject

    mail(to: @advisor.email, subject: t('mailers.user_mailer.notify_match_status.subject', company_name: @company.name))
  end

  def remind_invitation(user)
    @user = user
    @institution = user.institution
    @token = @user.invitation_token

    mail(to: @user.email, subject: t('mailers.user_mailer.remind_invitation.subject', institution_name: @institution.name))
  end
end
