require 'rails_helper'

RSpec.describe "appointments/edit", type: :view do
  before(:each) do
    @appointment = assign(:appointment, Appointment.create!(
      :first_name => "MyString",
      :last_name => "MyString",
      :comments => "MyText"
    ))
  end

  it "renders the edit appointment form" do
    render

    assert_select "form[action=?][method=?]", appointment_path(@appointment), "post" do

      assert_select "input#appointment_first_name[name=?]", "appointment[first_name]"

      assert_select "input#appointment_last_name[name=?]", "appointment[last_name]"

      assert_select "textarea#appointment_comments[name=?]", "appointment[comments]"
    end
  end
end
