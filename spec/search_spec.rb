require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Search" do
  describe "exclude_retweets" do
    before(:each) do
      @bot = Chatterbot::Bot.new
    end

    it "should tack onto query" do
      @bot.exclude_retweets("foo").should == ("foo -include:retweets")
    end

    it "shouldn't tack onto query" do
      @bot.exclude_retweets("foo -include:retweets").should == ("foo -include:retweets")
    end

    it "shouldn't tack onto query" do
      @bot.exclude_retweets("foo include:retweets").should == ("foo include:retweets")
    end
  end

  it "calls search" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:search)
    bot.search("foo")
  end
  
  it "calls init_client" do
    bot = test_bot
    bot.should_receive(:init_client).and_return(false)
    bot.search("foo")
  end

  it "calls update_since_id" do
    bot = test_bot

    bot.stub!(:client).and_return(fake_search(100))
    bot.should_receive(:update_since_id).with({'max_id' => 100, 'results' => []})

    bot.search("foo")
  end

  it "accepts multiple searches at once" do
    bot = test_bot
    #bot = Chatterbot::Bot.new

    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo -include:retweets", {})
    bot.client.should_receive(:search).with("bar -include:retweets", {})    

    bot.search(["foo", "bar"])
  end

  it "accepts extra params" do
    bot = test_bot

    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo -include:retweets", {:lang => "en"})

    bot.search("foo", :lang => "en")
  end

  it "accepts a single search query" do
    bot = test_bot

    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo -include:retweets", {})

    bot.search("foo")
  end

  it "passes along since_id" do
    bot = test_bot
    bot.stub!(:since_id).and_return(123)
    
    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo -include:retweets", {:since_id => 123, :result_type => "recent"})

    bot.search("foo")
  end

  it "updates since_id when complete" do
    bot = test_bot
    results = fake_search(100, 1, 1000)

    bot.stub!(:client).and_return(results)
    
    bot.search("foo")
  end
  
  it "iterates results" do
    bot = test_bot
    bot.stub!(:client).and_return(fake_search(100, 3))
    indexes = []

    bot.search("foo") do |x|
      indexes << x[:index]
    end
    
    indexes.should == [1,2,3]
  end

  it "checks blacklist" do
    bot = test_bot
    bot.stub!(:client).and_return(fake_search(100, 3))
    
    bot.stub!(:on_blacklist?).and_return(true, false)
    
    indexes = []
    bot.search("foo") do |x|
      indexes << x[:index]
    end

    indexes.should == [2,3]
  end

end
