RSpec.configure do |c|
  c.mock_with :mocha
end

RSpec::Matchers.define :have_a_method_named do |name, arity|
  match do |mod|
    mod.method_defined?(name).should be_true
    mod.instance_method(name).arity.should == arity
  end
end
