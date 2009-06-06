Given /^the following define_attributes:$/ do |define_attributes|
  DefineAttribute.create!(define_attributes.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) define_attribute$/ do |pos|
  visit define_attributes_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following define_attributes:$/ do |define_attributes|
  define_attributes.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end
