Pod::Spec.new do |s|
  s.name         = 'DRTPFObjectDynamicProperties'
  s.version      = '0.0.1'
  s.homepage     = 'https://github.com/drodriguez/DRTPFObjectDynamicProperties'
  s.summary      = 'Easy Parse PFObject subclassing with automagic property implementations.'
  s.authors      = { 'Daniel Rodríguez Troitiño' => 'drodrigueztroitino@yahoo.es' }
  s.source       = { :git => 'https://github.com/drodriguez/DRTPFObjectDynamicProperties.git', :tag => '0.0.1' }
  s.platform     = :ios, '5.0' # CocoaPods spec is iOS-only
  s.source_files = 'Classes', 'Classes/common/*.{h,m}'
  s.license      = 'MIT'
  s.requires_arc = true
  s.dependency     'Parse', '~> 1.1.29'
end
