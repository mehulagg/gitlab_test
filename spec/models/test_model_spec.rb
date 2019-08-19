require 'spec_helper'

RSpec.describe TestModel, type: :model do
  it "saves precise values" do
    time = 1.day.ago

    subject.assign_attributes(build_at: time, build_tz_at: time, build_ts_at: time)
    subject.save!
    expect(subject.reload.attributes.slice(*%w[build_at build_tz_at build_ts_at]))
      .to eq('build_at' => time, 'build_tz_at' => time, 'build_ts_at' => time)
  end

  it 'saves with timecop' do
    Timecop.freeze do
      subject.assign_attributes(build_at: 1.day.ago, build_tz_at: 1.day.ago, build_ts_at: 1.day.ago)
      subject.save!
      expect(subject.reload.attributes.slice(*%w[build_at build_tz_at build_ts_at]))
        .to eq('build_at' => 1.day.ago, 'build_tz_at' => 1.day.ago, 'build_ts_at' => 1.day.ago)
    end
  end

  it 'does work with change matcher' do
    time = 1.day.ago

    expect do
      subject.assign_attributes(build_at: time, build_tz_at: time, build_ts_at: time)
      subject.save!
      subject.reload
    end.to change { subject.attributes.slice(*%w[build_at build_tz_at build_ts_at]) }
             .to('build_at' => time, 'build_tz_at' => time, 'build_ts_at' => time)
  end

  it 'does work with simple matcher' do
    time = 1.day.ago

    subject.assign_attributes(build_at: time, build_tz_at: time, build_ts_at: time)
    subject.save!
    subject.reload
    expect(subject.build_at).to eq time
    expect(subject.build_tz_at).to eq time
    expect(subject.build_ts_at).to eq time
  end
end
