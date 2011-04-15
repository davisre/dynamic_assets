
#
# Makes sure a string contains a given substring. The difference between these two:
#
#    my_string.should =~ /something/                  # Using a regex
#    my_string.should contain_string "something"      # Using this matcher
#
# is that this matcher will escape the string for you, so you can search for .*?%^ASQ
# and not get weird results.
#
RSpec::Matchers.define :contain_string do |expected|

  match do |actual|
    raise "Expected value has an unexpected type. It's #{expected.class} but should be String." unless
      expected.is_a?(String)
    raise "Actual value has an unexpected type. It's #{actual.class} but should be String." unless
      actual.is_a?(String)

    actual =~ /#{Regexp.escape(expected)}/
  end

  failure_message_for_should do |actual|
    "expected that \"#{actual}\" would contain \"#{expected}\""
  end

  failure_message_for_should_not do |actual|
    "expected that \"#{actual}\" would not contain \"#{expected}\""
  end

  description do
    "contain \"#{expected}\""
  end

end


#
# Example:  my_string.should start_with "ABCDE"
#
RSpec::Matchers.define :start_with do |expected|

  match do |actual|
    raise "Actual value has an unexpected type. It's #{actual.class} but should be String." unless
      actual.is_a?(String)

    actual =~ /^#{Regexp.escape("#{expected}")}/
  end

  failure_message_for_should do |actual|
    "expected that \"#{actual}\" would start with \"#{expected}\""
  end

  failure_message_for_should_not do |actual|
    "expected that \"#{actual}\" would not start with \"#{expected}\""
  end

  description do
    "start with \"#{expected}\""
  end

end
