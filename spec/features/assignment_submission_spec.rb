require 'rails_helper'

def signup_topic
  user = User.find_by_name("student2064")
  stub_current_user(user, user.role.name, user.role)
  visit '/student_task/list'
  visit '/sign_up_sheet/sign_up?id=1&topic_id=1' #signup topic
  visit '/student_task/list'
  click_link "Assignment1684"
  click_link "Your work"
end


describe "assignment submisstion test" do
  before(:each) do
    #create assignment and topic
    create(:assignment, name: "Assignment1684", directory_path: "Assignment1684")
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now + 1)
  end

  describe "submit hyperlink" do
    it "is able to submit a single valid link" do
      signup_topic
      fill_in 'submission', with: "https://www.ncsu.edu"
      click_on 'Upload link'
      expect(page).to have_content "https://www.ncsu.edu"
      #open the link and check content
      click_on "https://www.ncsu.edu"
      expect(page).to have_http_status(200)
      #new_window = page.driver.browser.window_handles.last
      #page.within_window new_window do
        #expect(page).to have_content "NC STATE NEWS"
      #end
    end

    it "should not submit invalid link" do
      signup_topic
      #invalid format url1
      fill_in 'submission', with: "wolfpack"
      click_on 'Upload link'
      expect(page).to have_content "The URL or URI is not valid"

      #invalid format url2
      fill_in 'submission', with: "http://wrongurl"
      click_on 'Upload link'
      #expect(page).to have_content "The URL or URI is not valid"

      #unconnectable url
      fill_in 'submission', with: "http://www.notexisted.com"
      click_on 'Upload link'
      #expect(page).to have_content "The URL or URI is not valid"

      #click_on "http://wrongurl"
      #expect(page).to have_http_status(404)
    end

    it "is able to submit multiple links" do
      signup_topic
      fill_in 'submission', with: "https://www.ncsu.edu"
      click_on 'Upload link'
      fill_in 'submission', with: "https://www.google.com"
      click_on 'Upload link'
      fill_in 'submission', with: "https://bing.com"
      click_on 'Upload link'
      expect(page).to have_content "https://www.ncsu.edu"
      expect(page).to have_content "https://www.google.com"
      expect(page).to have_content "https://bing.com"
    end

    it "should not submit duplicated link" do
      signup_topic
      fill_in 'submission', with: "https://google.com"
      click_on 'Upload link'
      expect(page).to have_content "https://google.com"
      fill_in 'submission', with: "https://google.com"
      click_on 'Upload link'
      expect(page).to have_content "You or your teammate(s) have already submitted the same hyperlink."
    end

    it "test5: submit empty link" do
      signup_topic
      #hyperlink is empty
      fill_in 'submission', with: ""
      click_on 'Upload link'
      expect(page).to have_content "The URL or URI is not valid. Reason: The hyperlink cannot be empty!"
      #hyperlink is "http://"
      fill_in 'submission', with: "http://"
      click_on 'Upload link'
      expect(page).to have_content "The URL or URI is not valid. Reason: bad URI(absolute but no path): http://"
    end

  end
  describe "submit file" do
    it "is able to submit single valid file" do
      signup_topic
      file_path = Rails.root + "spec/features/assignment_submission_txts/valid_assignment_file.txt"
      attach_file('uploaded_file', file_path)
      click_on 'Upload file'
      expect(page).to have_content "valid_assignment_file.txt"
      expect(File).to exist("#{Rails.root}/pg_data/instructor6/csc517/test/Assignment1684/0/valid_assignment_file.txt")

      #check content of the uploaded file
      file_path = Rails.root + "pg_data/instructor6/csc517/test/Assignment1684/0/valid_assignment_file.txt"
      expect(File).to exist(file_path)
      expect(File.read(file_path)).to have_content "valid_assignment_file: This is a .txt file to test assignment submission."
    end

    it "is able to submit multiple valid files" do
      signup_topic
      #upload file1
      file_path = Rails.root + "spec/features/assignment_submission_txts/valid_assignment_file.txt"
      attach_file('uploaded_file', file_path)
      click_on 'Upload file'
      #upload file2
      file_path = Rails.root + "spec/features/assignment_submission_txts/valid_assignment_file2.txt"
      attach_file('uploaded_file', file_path)
      click_on 'Upload file'
      expect(page).to have_content "valid_assignment_file.txt"
      expect(page).to have_content "valid_assignment_file2.txt"

      #check content of the uploaded file
      #file1
      file_path = Rails.root + "pg_data/instructor6/csc517/test/Assignment1684/0/valid_assignment_file.txt"
      expect(File).to exist(file_path)
      expect(File.read(file_path)).to have_content "valid_assignment_file: This is a .txt file to test assignment submission."
      #file2
      file_path = Rails.root + "pg_data/instructor6/csc517/test/Assignment1684/0/valid_assignment_file2.txt"
      expect(File).to exist(file_path)
      expect(File.read(file_path)).to have_content "valid_assignment_file2: This is a .txt file to test assignment submission."
    end

  end

end
