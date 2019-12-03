namespace :import_dump do
  def setup_tunnel
    tunnel_command = 'scalingo -a reso-production db-tunnel SCALINGO_POSTGRESQL_URL'
    @tunnel_pid = fork{ exec tunnel_command }
  end

  def kill_tunnel
    Process.kill('QUIT', @tunnel_pid)
  end

  task :dump do
    setup_tunnel

    sleep 2

    env = `scalingo -a reso-production env`.lines
    pg_url = env.find{ |i| i[/SCALINGO_POSTGRESQL_URL=/] }
    pw = pg_url[/.*:(.*)@/,1]

    sh "PGPASSWORD=#{pw} pg_dump --no-owner --no-acl e_conseils_2947 > tmp/export.pgsql  -h localhost -p 10000 -U e_conseils_2947 -o"

    kill_tunnel
  end

  task :import do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    dbuser = YAML.load_file('config/database.yml').dig('development', 'username')

    sh "psql place-des-entreprises-development -f tmp/export.pgsql -U #{dbuser}"

    sh 'rm tmp/export.pgsql'

    Rake::Task['db:migrate'].invoke

    Rake::Task['db:environment:set'].invoke('RAILS_ENV=development')
  end

  WHITELISTED_MODELS = %w[
    Territory
    Antenne
    Institution
    Commune
    Landing
    Theme
    Subject
  ]

  ANONYMIZED_ATTRIBUTES = {
    'access_token' => -> { SecureRandom.hex(32) },
    'content' => -> { Faker::Lorem.paragraph },
    'description' => -> { Faker::Lorem.paragraph },
    'title' => -> { Faker::Lorem.sentence },
    'expert_full_name' => -> { Faker::Name.name },
    'full_name' => -> { Faker::Name.name },
    'phone_number' => -> { Faker::PhoneNumber.phone_number },
    'expert_institution_name' => -> { Faker::Company.name },
    'institution' => -> { Faker::Company.name },
    'name' => -> { Faker::Company.name + ' ' + Faker::Company.industry }, # institution and antenne names must be unique
    'role' => -> { Faker::Job.title },
    'label' => -> { Faker::Lorem.word },
    'current_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
    'last_sign_in_ip' => -> { Faker::Internet.ip_v4_address },
    'email' => -> { Faker::Internet.email },
    'unconfirmed_email' => -> { Faker::Internet.email },
    'legal_form_code' => -> { rand(1_000..9_999).to_s },
    'query' => -> { Faker::Lorem.word },
    'readable_locality' => -> { Faker::Address.city },
    'siren' => -> { Faker::Company.french_siren_number },
    'siret' => -> { Faker::Company.french_siret_number }
  }

  task anonymize: :environment do
    ApplicationRecord.descendants.each do |klass|
      next if WHITELISTED_MODELS.include?(klass.to_s)

      attributes = klass.attribute_names & ANONYMIZED_ATTRIBUTES.keys
      puts "#{klass} #{klass.all.count} #{attributes}"
      if attributes.present?
        klass.transaction do
          klass.all.each do |record|
            values = attributes.map { |attribute| [attribute, ANONYMIZED_ATTRIBUTES[attribute].call] }.to_h
            record.update_columns(values)
          end
        end
      end
    end
  end

  task all: %i[dump import anonymize]
end

desc 'import anonymized production data in development db'
task import_dump: %w[import_dump:all]
