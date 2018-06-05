# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'OCRDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'GPUImage'
  pod 'TesseractOCRiOS'
  pod 'MBProgressHUD'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          

          if  target.name == 'TesseractOCRiOS'
              target.build_configurations.each do |config|
                  config.build_settings['ENABLE_BITCODE'] = 'NO'
              end
          end
      end
      end

  # Pods for OCRDemo

  target 'OCRDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
