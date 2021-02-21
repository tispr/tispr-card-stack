Pod::Spec.new do |s|

    s.name = "TisprCardStack"
    s.version = "3.0.0"
    s.summary = "Swipable, customizable card stack view, Tinder like card stack view based on UICollectionView. Cards UI"

    s.description  = "Library that allows to have cards UI, like Tinder and Potluck. it is based on CollectionView. Works on iOS 10, Swift4"

    s.license      = { :type => "Apache 2.0 License", :file => "LICENSE.txt" }

    s.homepage = "https://github.com/tispr/tispr-card-stack"

    s.authors            = { 'Andrei Pitsko' => 'andrei.pitsko@gmail.com' }
    s.social_media_url   = "http://twitter.com/tispr"

    s.source = { :git => "https://github.com/tispr/tispr-card-stack.git", :tag => s.version }

    s.ios.deployment_target = "10.0"

    s.source_files  = "TisprCardStack/TisprCardStack/*.swift"
    
    s.requires_arc = true
    
end
