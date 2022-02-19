Pod::Spec.new do |s|
  
  # Basic Info
  
  s.name              = "YMFF"
  s.version           = "3.0.0-beta.1"
  s.summary           = "Feature management made easy."
  
  s.description       = <<-DESC
  YMFF is a nice little library that makes management of features
  with feature flags—and management of the feature flags themselves—a bliss.
                        DESC
  
  s.homepage          = "https://github.com/yakovmanshin/YMFF"
  s.readme            = "https://github.com/yakovmanshin/YMFF/blob/main/README.md"
  s.documentation_url = "https://opensource.ym.dev/YMFF/"
  
  s.license           = { :type => "Apache License, version 2.0", :file => "LICENSE" }
  
  s.author            = { "Yakov Manshin" => "contact@yakovmanshin.com" }
  s.social_media_url  = "https://github.com/yakovmanshin"
  
  # Sources & Build Settings
  
  s.source            = { :git => "https://github.com/yakovmanshin/YMFF.git", :tag => "#{s.version}" }
  
  s.swift_version     = "5.3"
  s.osx.deployment_target     = "10.13"
  s.ios.deployment_target     = "11.0"
  
  # Subspecs
  
  s.default_subspec   = "YMFF"
  
  s.subspec "YMFF" do |is|
    is.source_files = "Sources/YMFF/**/*.{swift}"
    is.dependency "YMFF/YMFFProtocols"
  end
  
  s.subspec "YMFFProtocols" do |ps|
    ps.source_files = "Sources/YMFFProtocols/**/*.{swift}"
  end
  
  s.test_spec "Tests" do |ts|
    ts.source_files = "Tests/YMFFTests/**/*.{swift}"
    ts.dependency "YMFF/YMFF"
  end
  
end
