# frozen_string_literal: true

RSpec.shared_examples 'a milestoneish' do |timebox_type|
  describe "#percent_complete" do
    it "does not count open issues" do
      timebox.issues << issue
      expect(timebox.percent_complete).to eq(0)
    end

    it "counts closed issues" do
      issue.close
      timebox.issues << issue
      expect(timebox.percent_complete).to eq(100)
    end

    it "recovers from dividing by zero" do
      expect(timebox.percent_complete).to eq(0)
    end
  end

  describe '#expired?' do
    context "expired" do
      before do
        allow(timebox).to receive(:due_date).and_return(Date.today.prev_year)
      end

      it 'returns true when due_date is in the past' do
        expect(timebox.expired?).to be_truthy
      end
    end

    context "not expired" do
      before do
        allow(timebox).to receive(:due_date).and_return(Date.today.next_year)
      end

      it 'returns false when due_date is in the future' do
        expect(timebox.expired?).to be_falsey
      end
    end
  end

  describe '#upcoming?' do
    it 'returns true when start_date is in the future' do
      timebox = build(timebox_type, start_date: Time.now + 1.month)
      expect(timebox.upcoming?).to be_truthy
    end

    it 'returns false when start_date is in the past' do
      timebox = build(timebox_type, start_date: Date.today.prev_year)
      expect(timebox.upcoming?).to be_falsey
    end
  end
end
