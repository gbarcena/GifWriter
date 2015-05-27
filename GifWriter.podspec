Pod::Spec.new do |s|
  s.name             = "GifWriter"
  s.version          = "1.0.0"
  s.summary          = "An easy way to write a gif to a file."
  s.homepage         = "https://github.com/gbarcena/GifWriter"
  s.license          = 'MIT'
  s.author           = { "Gustavo" => "gustavo@barcena.me" }
  s.source           = { :git => "https://github.com/gbarcena/GifWriter.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'LoopingVideoView/Source/*'

  s.frameworks = 'UIKit', 'MobileCoreServices', 'ImageIO'
end
