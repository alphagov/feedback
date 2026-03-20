RSpec.shared_examples_for "Service Feedback" do |path|
  it "displays no promotion when there is no promotion choice" do
    stub_conditional_loader_returns_content_item_for_path(path, payload)
    visit(path)

    expect(page).not_to have_selector(".promotion")
  end

  it "displays an electric car promotion when found in the content item" do
    electric_can_promotion_payload = payload.merge(details: {
      promotion: {
        url: "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        category: "electric_vehicle",
      },
    })

    stub_conditional_loader_returns_content_item_for_path(path, electric_can_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.electric_vehicle.title"))
  end

  it "displays an organ donation promotion when found in the content item" do
    organ_donation_promotion_payload = payload.merge(details: {
      promotion: {
        url: "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        category: "organ_donor",
      },
    })

    stub_conditional_loader_returns_content_item_for_path(path, organ_donation_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.organ_donor.title"))
  end

  it "displays an MOT promotion when found in the content item" do
    mot_promotion_payload = payload.merge(details: {
      promotion: {
        url: "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        category: "mot_reminder",
      },
    })

    stub_conditional_loader_returns_content_item_for_path(path, mot_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.mot_reminder.title"))
  end

  it "does not show survey for legacy base paths" do
    do_not_show_survey_for_legacy_base_paths_payload = payload.merge({
      base_path: "/done/transaction-finished",
    })

    stub_conditional_loader_returns_content_item_for_path("/done/transaction-finished", do_not_show_survey_for_legacy_base_paths_payload)

    visit("/done/transaction-finished")
    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.thanks_for_visiting"))
  end
end
