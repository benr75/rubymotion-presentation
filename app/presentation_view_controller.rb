class PresentationViewController < UIViewController
 
  def loadView
    self.view = UIView.alloc.init
  end
  
  def viewDidLoad
    @imageIndex = 0
    
    @tweets = []

    @imageArray = [
                    [UIImage.imageNamed('xcellent.png'), "We're HIRING!!!!!"], 
                   [UIImage.imageNamed('sponsors.png'), "THANK YOU!"], 
                   [UIImage.imageNamed('iosdevcamp.jpg'), "August 2, 2008"],
                   [UIImage.imageNamed('rubymotion.png'), "RUBY"],
                   [UIImage.imageNamed('freak.jpeg'), "Freak"],
                   [UIImage.imageNamed('buy.png'), "Not Free"],
                   [UIImage.imageNamed('irz.png'), "@irz"],
                   [UIImage.imageNamed('appstore.png'), "App Store, YES!"], 
                   [UIImage.imageNamed('compiled.png'),"COMPILED!"],
                   [UIImage.imageNamed('runtime.png'), "RUNTIME"]
                  ]
    
    @theImage = UIImageView.alloc.init
    @theImage.image = @imageArray[0][0]
    @theImage.frame = getImageFrame
    
    self.view.addSubview(@theImage)
    
    @label = make_label(@imageArray[0][1], [[0,0], [1024,80]], UIColor.lightGrayColor, UIColor.whiteColor, UIFont.boldSystemFontOfSize(34))
    self.view.addSubview(@label)

    @tweet_label = make_label("#iOSDevCamp", [[0,80], [1024,80]], UIColor.lightGrayColor, UIColor.whiteColor, UIFont.boldSystemFontOfSize(16))
    self.view.addSubview(@tweet_label)
    
    self.view.userInteractionEnabled = true    

    tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:'showNext')
    self.view.addGestureRecognizer(tap)

    swipe = UISwipeGestureRecognizer.alloc.initWithTarget(self, action:'showSwipe')
    self.view.addGestureRecognizer(swipe)
    
    self.fetch_tweets
    @timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector:'show_tweets', userInfo:nil, repeats:true)

  end
  
  def showNext

    @imageIndex = @imageIndex + 1
    @imageIndex = 0 unless @imageIndex < @imageArray.length
    @theImage.image = @imageArray[@imageIndex][0]
    @theImage.frame = getImageFrame

    UIView.animateWithDuration(0.5,
                               animations:lambda {
                                   @label.alpha = 0
                                   @label.transform = CGAffineTransformMakeScale(0.1, 0.1)
                               },
                               completion:lambda { |finished|
                                   @label.text = @imageArray[@imageIndex][1]
                                   UIView.animateWithDuration(0.5,
                                                    animations:lambda {
                                                        @label.alpha = 1
                                                        @label.transform = CGAffineTransformIdentity
                                                    })
                               })
  end

  def shouldAutorotateToInterfaceOrientation(*)
    return UIInterfaceOrientationLandscapeLeft
  end

  def showSwipe
    @theImage.image = UIImage.imageNamed('rainbows.jpeg')
    @theImage.frame = CGRectMake(0, 0, @theImage.image.size.width, @theImage.image.size.height)
    @label.text = "SWIPE! SWIPE! SWIPE!"
  end
  
  def make_label(text, frame, background_color, font_color, font_size)
    label = UILabel.alloc.initWithFrame(frame)
    label.backgroundColor = background_color
    label.text = text
    label.font = font_size
    label.textColor = font_color
    label.textAlignment = UITextAlignmentCenter
    label
  end

  def getImageFrame
    CGRectMake(0, 160, @theImage.image.size.width, @theImage.image.size.height)
  end

  def fetch_tweets
    url = "http://search.twitter.com/search.json?q=iOSDevCamp"

    @tweets.clear
    Dispatch::Queue.concurrent.async do 
      error_ptr = Pointer.new(:object)
      data = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(url), options:NSDataReadingUncached, error:error_ptr)
      unless data
        presentError error_ptr[0]
        return
      end
      json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      unless json
        presentError error_ptr[0]
        return
      end

      new_tweets = []
      json['results'].each do |dict|
        new_tweets << Tweet.new(dict)
      end

      Dispatch::Queue.main.sync { load_tweets(new_tweets) }
    end
  end

  def show_tweets
    @tweet_label.text = @tweets[@imageIndex].message
  end

  def load_tweets(tweets)
    @tweets = tweets
  end
  
end