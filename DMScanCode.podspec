Pod::Spec.new do |s|
  s.name = "DMScanCode"
  s.version = "1.0.0"
  s.summary = "Scan"
  s.homepage = "https://github.com/dulingkang/DMScanCode"
  s.license = 'MIT'
  s.authors = { "Shawn Du" => 'dulingkang@163.com' }

  s.platform = :ios, "7.0"
  s.requires_arc = true
  s.source = { :git => 'https://github.com/dulingkang/DMScanCode.git', :tag => s.version}
  s.public_header_files = 'DMScanCode/Other/DMScanCode.h'
  s.source_files = '{DMCapture}/*.{h,m}'
  s.description = 'Scan bar code and QR code'
end
