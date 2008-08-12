namespace :radiant do
  namespace :extensions do
    namespace :location do
      
      desc "Runs the migration of the Location extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          LocationExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          LocationExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Location to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[LocationExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(LocationExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
