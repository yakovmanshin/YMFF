Pod::Spec.new do |s|
  
  # Root
  
  s.name              = "YMFF"
  s.version           = "3.1.0"
  s.swift_version     = "5.8"
  s.authors           = { "Yakov Manshin" => "git@yakovmanshin.com" }
  s.license           = { :type => "Apache License, version 2.0", :file => "LICENSE" }
  s.homepage          = "https://github.com/yakovmanshin/YMFF"
  s.readme            = "https://github.com/yakovmanshin/YMFF/blob/main/README.md"
  s.source            = { :git => "https://github.com/yakovmanshin/YMFF.git", :tag => "#{s.version}" }
  s.summary           = "Feature management made easy."
  s.description       = <<-DESC
  YMFF is a nice little library that makes management of features
  with feature flags—and management of the feature flags themselves—a bliss.
                        DESC
  
  # Platform
  
  s.ios.deployment_target     = "13.0"
  s.osx.deployment_target     = "10.15"
  
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
