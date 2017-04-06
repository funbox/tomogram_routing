require 'spec_helper'

RSpec.describe TomogramRouting::Tomogram do
  subject do
    described_class.craft(tomogram)
  end

  describe '#find_request' do
    let(:method) { 'POST' }
    let(:tomogram) { MultiJson.dump([{}]) }
    let(:path) { '/status' }

    context 'if not found in the tomogram' do
      it 'returns an empty string' do
        expect(subject.find_request(method: method, path: path)).to eq(nil)
      end
    end

    context 'if found in the tomogram' do
      let(:request1) { { 'path' => '/status', 'method' => 'POST' } }
      let(:request2) { { 'path' => '/status/{id}', 'method' => 'DELETE' } }
      let(:tomogram) do
        MultiJson.dump(
          [
            request1,
            request2
          ]
        )
      end

      context 'if slash at the end' do
        let(:path) { '/status/' }

        it 'return path withoud slash at the end' do
          expect(subject.find_request(method: method, path: path)).to eq(request1)
        end
      end

      context 'if request with query parameters' do
        let(:path) { '/status/?a=b&c=d' }

        it 'ignores query parameters' do
          expect(subject.find_request(method: method, path: path)).to eq(request1)
        end
      end

      context 'without parameters' do
        it 'return path' do
          expect(subject.find_request(method: method, path: path)).to eq(request1)
        end
      end

      context 'with a parameter' do
        let(:path) { '/status/1' }
        let(:method) { 'DELETE' }

        it 'returns the modified path' do
          expect(subject.find_request(method: method, path: path)).to eq(request2)
        end
      end
    end

    context 'if inserted' do
      let(:request1) { MultiJson.load(File.read('spec/fixtures/request1.json')) }
      let(:request2) { MultiJson.load(File.read('spec/fixtures/request2.json')) }
      let(:request3) { MultiJson.load(File.read('spec/fixtures/request3.json')) }
      let(:tomogram) do
        MultiJson.dump(
          [
            request1,
            request2,
            request3
          ]
        )
      end
      let(:path) { '/users/37812539-99af-4d7c-b86f-b756e3d1a211/pokemons' }
      let(:method) { 'GET' }

      it 'returns the modified path' do
        expect(subject.find_request(method: method, path: path)).to eq(request3)
      end
    end
  end
end
