# frozen_string_literal: true

Gitlab::Seeder.quiet do
  # The data set takes approximately 2 minutes to load,
  # so its put behind the flag. To seed this data use the flag and the filter:
  # SEED_PRODUCT_ANALYTICS_EVENTS=1 FILTER=product_analytics_events rake db:seed_fu
  flag = 'SEED_PRODUCT_ANALYTICS_EVENTS'

  if ENV[flag]
    Project.all.sample(2).each do |project|
      # Let's generate approx a week of events from now into the past with 1 minute step.
      # To add some differentiation we add a random offset of up to 30 seconds.
      10000.times do |i|
        dvce_created_tstamp = DateTime.now - i.minute - rand(30).seconds

        # Add a random delay to collector timestamp. Up to 2 seconds.
        collector_tstamp = dvce_created_tstamp + rand(3).second

        ProductAnalyticsEvent.create!(
          project_id: project.id,
          platform: ["web", "mob", "mob", "app"].sample,
          etl_tstamp: nil,
          collector_tstamp: collector_tstamp,
          dvce_created_tstamp: dvce_created_tstamp,
          event: nil,
          event_id: SecureRandom.uuid,
          txn_id: nil,
          name_tracker: "sp",
          v_tracker: "js-2.14.0",
          v_collector: "GitLab 12.9.0-pre",
          v_etl: "GitLab 12.9.0-pre",
          user_id: nil,
          user_ipaddress: nil,
          user_fingerprint: nil,
          domain_userid: SecureRandom.uuid,
          domain_sessionidx: 4,
          network_userid: nil,
          geo_country: nil,
          geo_region: nil,
          geo_city: nil,
          geo_zipcode: nil,
          geo_latitude: nil,
          geo_longitude: nil,
          geo_region_name: nil,
          ip_isp: nil,
          ip_organization: nil,
          ip_domain: nil,
          ip_netspeed: nil,
          page_url: "#{project.web_url}/-/product_analytics/test",
          page_title: nil,
          page_referrer: "#{project.web_url}/-/product_analytics/test",
          page_urlscheme: nil,
          page_urlhost: nil,
          page_urlport: nil,
          page_urlpath: nil,
          page_urlquery: nil,
          page_urlfragment: nil,
          refr_urlscheme: nil,
          refr_urlhost: nil,
          refr_urlport: nil,
          refr_urlpath: nil,
          refr_urlquery: nil,
          refr_urlfragment: nil,
          refr_medium: nil,
          refr_source: nil,
          refr_term: nil,
          mkt_medium: nil,
          mkt_source: nil,
          mkt_term: nil,
          mkt_content: nil,
          mkt_campaign: nil,
          se_category: nil,
          se_action: nil,
          se_label: nil,
          se_property: nil,
          se_value: nil,
          tr_orderid: nil,
          tr_affiliation: nil,
          tr_total: nil,
          tr_tax: nil,
          tr_shipping: nil,
          tr_city: nil,
          tr_state: nil,
          tr_country: nil,
          ti_orderid: nil,
          ti_sku: nil,
          ti_name: nil,
          ti_category: nil,
          ti_price: nil,
          ti_quantity: nil,
          pp_xoffset_min: nil,
          pp_xoffset_max: nil,
          pp_yoffset_min: nil,
          pp_yoffset_max: nil,
          useragent: nil,
          br_name: nil,
          br_family: nil,
          br_version: nil,
          br_type: nil,
          br_renderengine: nil,
          br_lang: ["en-US", "en-US", "en-GB", "nl", "fi"].sample, # https://www.andiamo.co.uk/resources/iso-language-codes/
          br_features_pdf: true,
          br_features_flash: nil,
          br_features_java: nil,
          br_features_director: nil,
          br_features_quicktime: nil,
          br_features_realplayer: nil,
          br_features_windowsmedia: nil,
          br_features_gears: nil,
          br_features_silverlight: nil,
          br_cookies: [true, true, true, false].sample,
          br_colordepth: ["24", "24", "16", "8"].sample,
          br_viewwidth: nil,
          br_viewheight: nil,
          os_name: nil,
          os_family: nil,
          os_manufacturer: nil,
          os_timezone: ["America/Los_Angeles", "America/Los_Angeles", "America/Lima", "Asia/Dubai", "Africa/Bangui"].sample, # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
          dvce_type: nil,
          dvce_ismobile: nil,
          dvce_screenwidth: nil,
          dvce_screenheight: nil,
          doc_charset: ["UTF-8", "UTF-8", "UTF-8", "DOS", "EUC"].sample,
          doc_width: nil,
          doc_height: nil,
          tr_currency: nil,
          tr_total_base: nil,
          tr_tax_base: nil,
          tr_shipping_base: nil,
          ti_currency: nil,
          ti_price_base: nil,
          base_currency: nil,
          geo_timezone: nil,
          mkt_clickid: nil,
          mkt_network: nil,
          etl_tags: nil,
          dvce_sent_tstamp: nil,
          refr_domain_userid: nil,
          refr_dvce_tstamp: nil,
          domain_sessionid: SecureRandom.uuid,
          derived_tstamp: nil,
          event_vendor: nil,
          event_name: nil,
          event_format: nil,
          event_version: nil,
          event_fingerprint: nil,
          true_tstamp: nil
        )
      end

      Feature.enable(:product_analytics, project)

      puts "Product analytics feature was enabled for #{project.full_path}"
      puts "10K events added to #{project.full_path}"
    end
  else
    puts "Skipped. Use the `#{flag}` environment variable to enable."
  end
end
