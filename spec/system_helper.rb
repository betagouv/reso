def check_links_text(context)
  within(context) do
    all_links = all("a").map(&:text) # get text for all links
    all_links.each do |i|
      puts i
    end
  end
end

def create_base_dummy_data
  create(:antenne)
  create(:badge)
  create(:commune)
  create(:company)
  create(:contact_with_email)
  create(:diagnosis)
  create(:expert_subject)
  create(:expert)
  create(:facility)
  create(:feedback, :for_need)
  create(:institution_subject)
  create(:institution, show_on_list: true)
  create(:landing_option)
  create(:landing_topic)
  create(:landing)
  create(:match)
  create(:subject)
  create(:theme)
  create(:user)
end
