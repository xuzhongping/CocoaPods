Pod::Spec.new do |s|
    s.name         = 'AppleDY'
    s.version      = '0.2.0'
    s.summary      = 'Crash防护组件'
    s.homepage     = 'https://github/source/iOS-AppleDY'
    s.license      = 'MIT'
    s.authors      = {'xxx' => 'xxx'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://github/source/iOS-AppleDY.git', :tag => s.version}
    
    s.source_files = 'AppleDY/AppleDY/**/*.{h,m}'
#    s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '-lObjC' }
    # s.vendored_frameworks = 'Apple.framework'
    s.dependency 'Apple'
end

