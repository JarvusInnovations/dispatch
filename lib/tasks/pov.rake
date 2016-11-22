namespace :pov do
  require 'json'

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
            o = Opportunity.create

            o.description = opportunity['description']
            o.original_url = opportunity['originalUrl']

            if opportunity['title'] != nil
                o.title = opportunity['title']
            else
                o.title = opportunity['description']
            end

            if opportunity['retrieveDate'] != nil
                o.submitted_at = Date.parse(opportunity['retrieveDate'])
            end

            d = Department.find_by_name(opportunity['sourceDescription'])

            if d != nil
                o.department = d
            elsif opportunity['sourceDescription'] != nil
                d = Department.create
                d.name = opportunity['sourceDescription']
                d.save!

                o.department = d
            end

            opportunity["attachedDocuments"].each do |attachment|
                a = Attachment.create
                
                File.open(attachment['path'], 'r') do |f|
                    a.upload = f
                    a.name = attachment['text']
                    o.attachments.push(a)
                  end
            end

            o.created_by_user = u
            o.approved_at = DateTime.now
            o.save!
        end
    end
  end
end