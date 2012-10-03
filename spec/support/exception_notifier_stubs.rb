module ExceptionNotifierStubs

  class Deliverer
    def self.deliver
    end
  end

  def setup_exception_notifier_stubs
    ExceptionNotifier::Notifier.stub(:background_exception_notification).and_return(Deliverer)
  end
end

RSpec.configure do |config|
  config.include ExceptionNotifierStubs
  config.before :each do
    setup_exception_notifier_stubs
  end
end
