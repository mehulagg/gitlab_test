RSpec.shared_examples 'url validator examples' do |schemes|
  let(:validator) { described_class.new(attributes: [:link_url], **options) }
  let!(:badge) { build(:badge, link_url: 'http://www.example.com') }

  subject { validator.validate_each(badge, :link_url, badge.link_url) }

  describe '#validates_each' do
    context 'with no options' do
      let(:options) { {} }

      it "allows #{schemes.join(',')} schemes by default" do
        expect(validator.options[:schemes]).to eq schemes
      end

      it 'checks that the url structure is valid' do
        badge.link_url = "#{badge.link_url}:invalid_port"

        subject

        expect(badge.errors.empty?).to be_falsey
      end
    end

    context 'with schemes' do
      let(:options) { { schemes: %w(http) } }

      it 'allows urls with the defined schemes' do
        subject

        expect(badge.errors.empty?).to be_truthy
      end

      it 'add error if the url scheme does not match the selected ones' do
        badge.link_url = 'https://www.example.com'

        subject

        expect(badge.errors.empty?).to be_falsey
      end
    end
  end
end
