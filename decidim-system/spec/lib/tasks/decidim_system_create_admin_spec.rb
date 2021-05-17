# frozen_string_literal: true

require "spec_helper"

describe "decidim_system:create_admin", type: :task do
  let(:email) { "system@example.org" }
  let(:password) { "Test123456" }
  let(:password_confirmation) { password }

  let(:months) { 3 }
  let(:threshold) { Time.current - months.months }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    allow($stdin).to receive(:gets).and_return(email, password, password_confirmation)

    expect { task.execute }.not_to raise_error
  end

  context "when there are existing system admins" do
    let!(:system_admin) { create(:admin) }

    it "warns that there are already existing admins" do
      allow($stdin).to receive(:gets).and_return(email, password, password_confirmation)

      task.execute
      expect($stdout.string).to include("currently there are existing system admins")
    end
  end

  context "when provided data is valid" do
    it "creates an admin" do
      allow($stdin).to receive(:gets).and_return(email, password, password_confirmation)

      expect { task.execute }.to change { Decidim::System::Admin.count }.by(1)
      expect($stdout.string).to include("System admin created successfully")
    end
  end

  context "when provided data is invalid" do
    let(:email) { "invalid" }
    let(:password_confirmation) { "invalid" }

    it "prevents creation of admin and displays validation errors" do
      allow($stdin).to receive(:gets).and_return(email, password, password_confirmation)

      expect { task.execute }.not_to(change { Decidim::System::Admin.count })

      expect($stdout.string).to include("Some errors prevented creation of admin")
      expect($stdout.string).to include("Email is invalid")
      expect($stdout.string).to include("Password confirmation doesn't match Password")
    end
  end
end
