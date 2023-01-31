RSpec.shared_examples_for "Service Feedback" do |path|
  it "displays no promotion when there is no promotion choice" do
    stub_content_store_has_item("/#{slug}", payload)
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

    stub_content_store_has_item(path, electric_can_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.electric_car_promotion"))
  end

  it "displays an organ donation promotion when found in the content item" do
    organ_donation_promotion_payload = payload.merge(details: {
      promotion: {
        url: "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        category: "organ_donor",
      },
    })

    stub_content_store_has_item(path, organ_donation_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.organ_donation"))
  end

  it "displays an MOT promotion when found in the content item" do
    mot_promotion_payload = payload.merge(details: {
      promotion: {
        url: "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        category: "mot_reminder",
      },
    })

    stub_content_store_has_item(path, mot_promotion_payload)

    visit(path)

    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.mot_promotion"))
  end

  it "does not show survey for legacy slugs" do
    do_not_show_survey_for_legacy_slugs_payload = payload.merge({
      base_path: "/done/transaction-finished",
    })

    stub_content_store_has_item("/done/transaction-finished", do_not_show_survey_for_legacy_slugs_payload)

    visit("/done/transaction-finished")
    expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.thanks_for_visiting"))
  end
end
