namespace :pov do
  require 'json'

  task :generate, :environment do
    system "/Users/kevinclough/Projects/Jarvus/city-toolkit-hub/scraper/; node app-dispatch.js"
  end

  task :import, [:path] => :environment do |t, args|
    path = args[:path]
    if path.nil?
        puts 'path required'
    else
        opportunity_file = File.read(path)
        opportunities = JSON.parse(opportunity_file)

        u = User.find_by_email("admin@openvendorphilly.com")
        if u == nil
            u = User.create
            u.email = "admin@openvendorphilly.com"
            u.name = 'Open Vendor Admin'
            u.permission_level = 'admin'
            u.confirmed_at = Time.now
        end            

        opportunities.each do |opportunity|
            s = Source.find_by_name(opportunity['sourceDescription'])

            if s.present?
                existing_opportunity = Opportunity.where("source_id = ? AND title = ? AND description = ?", s.id, opportunity['title'], opportunity['description'])
                next if existing_opportunity.present?
            end

            if opportunity['status'] == nil || opportunity['status'] != 'Closed'
                closeDate = Date.parse(opportunity['closeDate']) rescue nil
                if closeDate == nil || closeDate.future?
                    o = Opportunity.create

                    o.description = opportunity['description']
                    o.original_url = opportunity['originalUrl']

                    if opportunity['title'] != nil
                        o.title = opportunity['title']
                    end

                    if opportunity['retrieveDate'] != nil
                        o.submitted_at = Date.parse(opportunity['retrieveDate'])
                    end

                    if opportunity['publishDate'] != nil
                        o.original_publish_date = Date.parse(opportunity['publishDate'])
                    else
                        o.original_publish_date = DateTime.now
                    end

                    if s != nil
                        o.source = s
                    elsif opportunity['sourceDescription'] != nil
                        s = Source.create
                        s.name = opportunity['sourceDescription']
                        s.save!

                        o.source = s
                    end

                    # Approve all non big ideas phl contracts
                    # Only allow questions on big ideas phl contracts
                    if opportunity['sourceDescription'] == '$32K and Under Small Contracts'
                        o.enable_questions = true
                    else
                        o.approved_at = DateTime.now
                    end

                    Array(opportunity["attachedDocuments"]).each do |attachment|
                        a = Attachment.create
                        
                        File.open(attachment['path'], 'r') do |f|
                            a.upload = f
                            a.name = attachment['text']
                            o.attachments.push(a)
                          end
                    end

                    o.created_by_user = u
                    o.save!
                end
            end
        end
    end
  end
end