Pod::Spec.new do |s|
s.name             = 'HHFloatingView'
s.module_name      = 'HHFloatingView'
s.version          = '1.0.0'
s.summary          = 'An easy to use and setup floating view for your app. 🎡'
s.description      = 'HHFloatingView is another options view which you can use to show basic options for your app.'
s.homepage         = 'https://github.com/hemangshah/HHFloatingView'
s.license          = 'MIT'
s.author           = { 'hemangshah' => 'hemangshah.in@gmail.com' }
s.source           = { :git => 'https://github.com/hemangshah/HHFloatingView.git', :tag => s.version.to_s }
s.platform     = :ios, '9.0'
s.requires_arc = true
s.source_files = 'HHFloatingView/Source/*.swift'
end
