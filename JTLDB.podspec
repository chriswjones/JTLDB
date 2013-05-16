#
# Be sure to run `pod spec lint JTLDB.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
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
  #s.exclude_files = 'Classes/Exclude'

  # A list of file patterns which select the header files that should be
  # made available to the application. If the pattern is a directory then the
  # path will automatically have '*.h' appended.
  #
  # If you do not explicitly set the list of public header files,
  # all headers of source_files will be made public.
  #
  # s.public_header_files = 'Classes/**/*.h'

  # A list of resources included with the Pod. These are copied into the
  # target bundle with a build phase script.
  #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # A list of paths to preserve after installing the Pod.
  # CocoaPods cleans by default any file that is not used.
  # Please don't include documentation, example, and test files.
  #
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.requires_arc = true

  # If you need to specify any other build settings, add them to the
  # xcconfig hash.
  #
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
