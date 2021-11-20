Pod::Spec.new do |s|
    s.name         = 'Apple'
    s.module_name  = 'Apple_XX'
    s.version      = '0.2.0'
    s.summary      = 'Crash防护组件'
    s.homepage     = 'https://phabricator.ushow.media/source/iOS-QMCrashKit'
    s.license      = 'MIT'
    s.authors      = {'xxx' => 'xxx@ushow.media'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://phabricator.ushow.media/source/iOS-QMCrashKit.git', :tag => s.version}
    
    # s.source_files = 'AppleDY/AppleDY/**/*.{h,m}'
#    s.pod_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '-lObjC' }
    s.vendored_frameworks = 'Apple.framework'
end

