require "rails_helper"

RSpec.describe RegistrationForm do
  describe "validations" do
    it "không hợp lệ nếu thiếu name" do
      form = described_class.new(name: nil, email: "a@example.com", password: "123456")

      expect(form).not_to be_valid
      expect(form.errors[:name]).to include("can't be blank")
    end

    it "không hợp lệ nếu thiếu email" do
      form = described_class.new(name: "Nguyễn Văn A", email: nil, password: "123456")

      expect(form).not_to be_valid
      expect(form.errors[:email]).to be_present
    end

    it "không hợp lệ nếu email sai định dạng" do
      form = described_class.new(name: "Nguyễn Văn A", email: "khong-phai-email", password: "123456")

      expect(form).not_to be_valid
      expect(form.errors[:email]).to be_present
    end

    it "không hợp lệ nếu thiếu password" do
      form = described_class.new(name: "Nguyễn Văn A", email: "a@example.com", password: nil)

      expect(form).not_to be_valid
      expect(form.errors[:password]).to be_present
    end

    it "không hợp lệ nếu phone_number sai định dạng" do
      form = described_class.new(name: "Nguyễn Văn A", email: "a@example.com", password: "123456", phone_number: "abc")

      expect(form).not_to be_valid
      expect(form.errors[:phone_number]).to be_present
    end

    it "hợp lệ khi có đủ name, email, password (phone_number optional)" do
      form = described_class.new(name: "Nguyễn Văn A", email: "a@example.com", password: "123456")

      expect(form).to be_valid
    end
  end

  describe "#save" do
    context "khi dữ liệu hợp lệ" do
      let(:attrs) do
        {
          name: "Trần Thị B",
          email: "tranthib@example.com",
          password: "123456",
          password_confirmation: "123456",
          phone_number: "0912345678"
        }
      end

      it "tạo mới 1 User" do
        expect { described_class.new(attrs).save }.to change(User, :count).by(1)
      end

      it "mã hoá password (không lưu plain text)" do
        form = described_class.new(attrs)
        form.save

        expect(form.user.password_digest).to be_present
        expect(form.user.authenticate("123456")).to be_truthy
      end

      it "tạo mới 1 UserProfile gắn với User vừa tạo, lưu đúng phone_number" do
        form = described_class.new(attrs)

        expect { form.save }.to change(UserProfile, :count).by(1)
        expect(form.user.user_profile.phone_number).to eq("0912345678")
      end

      it "trả về true" do
        expect(described_class.new(attrs).save).to be(true)
      end
    end

    context "khi dữ liệu không hợp lệ" do
      it "trả về false và không tạo User/UserProfile nào" do
        form = described_class.new(name: nil, email: "a@example.com", password: "123456")

        expect { form.save }.not_to change(User, :count)
        expect { form.save }.not_to change(UserProfile, :count)
        expect(form.save).to be(false)
      end
    end

    context "khi email đã tồn tại (uniqueness ở tầng DB)" do
      it "trả về false, không tạo user trùng email" do
        create(:user, email: "trung@example.com")
        form = described_class.new(name: "Người mới", email: "trung@example.com", password: "123456")

        expect { form.save }.not_to change(User, :count)
        expect(form.save).to be(false)
        expect(form.errors[:email]).to be_present
      end
    end

    context "khi UserProfile invalid ở tầng DB" do
      it "rollback: không để lại User mồ côi (không có UserProfile)" do
        allow_any_instance_of(User).to receive(:create_user_profile!).and_raise(
          ActiveRecord::RecordInvalid.new(UserProfile.new)
        )

        form = described_class.new(name: "Trần Thị B", email: "b@example.com", password: "123456")

        expect { form.save }.not_to change(User, :count)
      end
    end
  end
end
