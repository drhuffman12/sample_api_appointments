require 'rails_helper'

RSpec.describe "appointments/index", type: :view do
  before(:each) do
    assign(:appointments, [
      Appointment.create!(
        :first_name => "First Name",
        :last_name => "Last Name",
        :comments => "MyText"
      ),
      Appointment.create!(
        :first_name => "First Name",
        :last_name => "Last Name",
        :comments => "MyText"
      )
    ])
  end

  it "renders a list of appointments" do
    render
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
