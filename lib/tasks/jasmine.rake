desc "Run Jasmine tests"
task jasmine: :environment do
  sh "yarn run jasmine:ci"
end

desc "Run Jasmine tests in the browser"
task jasmine_browser: :environment do
  sh "yarn run jasmine:browser"
end
