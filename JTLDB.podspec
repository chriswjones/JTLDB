Pod::Spec.new do |s|
  s.name         = "JTLDB"
  s.version      = "0.1"
  s.summary      = "JTLDB is a fully asynchronous Objective-C SQLite wrapper."
  s.homepage     = "https://github.com/jtlsystems/JTLDB"
  s.license      = { 
  	:type => 'Apache 2.0', 
	:file => 'LICENSE' 
  }
  s.author       = { "Chris Jones" => "chrisjones12@me.com" }
  s.source       = {
   :git => "https://github.com/jtlsystems/JTLDB.git", 
   :tag => "0.1" 
  }
  s.platform     = :ios, '5.0'
  s.source_files = 'JTLDB/**/*.{c,h,m}'
  s.requires_arc = true
end
