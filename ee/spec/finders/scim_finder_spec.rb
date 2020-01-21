# frozen_string_literal: true

require 'spec_helper'

describe ScimFinder do
  let(:group) { create(:group) }
  let(:unused_params) { double }

  subject(:finder) { described_class.new(group) }

  describe '#search' do
    context 'without a SAML provider' do
      it 'returns an empty relation when there is no saml provider' do
        expect(finder.search(unused_params)).to eq Identity.none
      end
    end

    context 'SCIM/SAML is not enabled' do
      before do
        create(:saml_provider, group: group, enabled: false)
      end

      it 'returns an empty relation when SCIM/SAML is not enabled' do
        expect(finder.search(unused_params)).to eq Identity.none
      end
    end

    context 'with SCIM enabled' do
      let!(:saml_provider) { create(:saml_provider, group: group) }

      context 'with an eq filter' do
        let(:identities) { create_list(:group_saml_identity, 10, saml_provider: saml_provider) }
        let!(:identity) { identities.first }
        let!(:other_identity) { identities.last }

        it 'allows identity lookup by id/externalId' do
          expect(finder.search(filter: "id eq \"#{identity.extern_uid}\"")).to be_a ActiveRecord::Relation
          expect(finder.search(filter: "id eq \"#{identity.extern_uid}\"").first).to eq identity
          expect(finder.search(filter: "externalId eq \"#{identity.extern_uid}\"").first).to eq identity
        end

        it 'returns an empty list of results when the id is unknown' do
          expect(finder.search(filter: "id eq \"#{SecureRandom.uuid}\"")).to be_empty
        end

        it 'returns an empty list of results when the externalId is unknown' do
          expect(finder.search(filter: "externalId eq \"#{SecureRandom.uuid}\"")).to be_empty
        end

        it 'allows lookup by userName' do
          expect(finder.search(filter: "userName eq \"#{identity.user.username}\"").first).to eq identity
        end

        it 'allows finding identities that do not equal a userName' do
          expect(finder.search(filter: "userName ne \"#{identity.user.username}\"")).to match_array(identities - [identity])
        end

        it 'allows finding identities that do not equal an id' do
          expect(finder.search(filter: "id ne \"#{identity.extern_uid}\"")).to match_array(identities - [identity])
        end

        it 'finds identities with an externalId' do
          other_identity.update_column(:extern_uid, nil)
          expect(finder.search(filter: "externalId pr")).to match_array(identities - [other_identity])
        end

        it 'finds identities without an externalId' do
          other_identity.update_column(:extern_uid, nil)
          expect(finder.search(filter: "not (externalId pr)")).to match_array([other_identity])
        end

        it 'finds identities with a userName' do
          other_identity.user.update_column(:username, nil)
          expect(finder.search(filter: "userName pr")).to match_array(identities - [other_identity])
        end

        it 'finds identities without a userName' do
          other_identity.user.update_column(:username, nil)
          expect(finder.search(filter: "not (userName pr)")).to match_array([other_identity])
        end

        it 'finds identities that match A and B' do
          other_user = other_identity.user
          expect(finder.search(filter: "userName pr and not (userName eq \"#{other_user.username}\")")).to match_array(identities - [other_identity])
        end

        it 'finds identities that match username(a) or userName(b)' do
          expect(finder.search(filter: "userName eq \"#{identity.user.username}\" or userName eq \"#{other_identity.user.username}\"")).to match_array([identity, other_identity])
        end

        it 'finds identities that match id(a) or username(b)' do
          expect(finder.search(filter: "id eq \"#{identity.extern_uid}\" or userName eq \"#{other_identity.user.username}\"")).to match_array([identity, other_identity])
        end
      end

      context 'with unsupported filters' do
        it 'fails with unsupported operators' do
          expect do
            finder.search(filter: 'userName is "nick"')
          end.to raise_error(ScimFinder::UnsupportedFilter)
        end

        it 'fails when the attribute path is unsupported' do
          expect do
            finder.search(filter: 'user_name eq "nick"')
          end.to raise_error(ScimFinder::UnsupportedFilter)
        end
      end

      it 'returns all related identities if there is no filter' do
        create_list(:group_saml_identity, 2, saml_provider: saml_provider)

        expect(finder.search({}).count).to eq 2
      end

      it 'raises an error if the filter is unsupported' do
        expect { finder.search(filter: 'id lt 1') }.to raise_error(ScimFinder::UnsupportedFilter)
      end

      it 'raises an error if the attribute path is unsupported' do
        expect { finder.search(filter: 'displayName eq "name"').count }.to raise_error(ScimFinder::UnsupportedFilter)
      end
    end
  end
end
