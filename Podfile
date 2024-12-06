# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'STTR' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  #pod 'Firebase/Analytics'

  # Pods for STTR
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'GoogleSignIn'
  pod 'Firebase/Core' #, :modular_header => true
  #pod 'Firebase/Messaging', :modular_header => true
  pod 'SwiftKeychainWrapper'
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end

end
