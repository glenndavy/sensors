# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest', :test_folders => ["test","specs"]  do
  # with Minitest::Unit
  #watch(%r|^test/(.*)\/?test_(.*)\.rb|)
  #watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  #watch(%r|^test/test_helper\.rb|)    { "test" }

  # with Minitest::Spec
  watch(%r|^specs/(.*)_spec\.rb|)
  watch(%r|^lib/sensors.rb|)            { Dir['specs/**/[a-z]*_spec.rb'] }
  watch(%r|^lib/(.*)([^/]+)\.rb|)       { |m| "specs/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^specs/spec_helper\.rb|)     { "specs" }

  # Rails 3.2
  # watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/controllers/#{m[1]}_test.rb" }
  # watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  # watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/#{m[1]}_test.rb" }  
  
  # Rails
  # watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/functional/#{m[1]}_test.rb" }
  # watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  # watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/#{m[1]}_test.rb" }  
end
