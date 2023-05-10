require 'rails_helper'

RSpec.describe "DiscordWebhooks::Bot", type: :request do
  let(:now) { Time.now }
  context '#bot_action' do
    let(:signing_key) { Ed25519::SigningKey.new(['0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'].pack('H*')) }

    def generate_signature(timestamp, params)
      signature_payload = timestamp.to_i.to_s + params.to_json
      signing_key.sign(signature_payload).unpack('H*').first
    end

    def post_request(timestamp, params, signature: nil)
      signature ||= generate_signature(timestamp, params)
      post "/bot", params: params, as: :json, headers: {
        "HTTP_X_SIGNATURE_TIMESTAMP" => timestamp.to_i,
        "HTTP_X_SIGNATURE_ED25519" => signature
      }
    end

    around(:example) do |example|
      DiscordWebhooks.discord_public_key = signing_key.verify_key.to_bytes.unpack('H*').first
      Timecop.freeze(now) do
        example.run
      end
      DiscordWebhooks.discord_public_key = nil
    end

    describe "POST /bot" do
      context 'discord ping' do
        let(:params) { { "type" => 1, 'guild_id' => 'fakeGuildId', "some_other" => "params" } }

        it 'should handle a good ping' do
          post_request(now, params)

          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq({ 'type' => 1 })
        end

        it 'should fail with bad signature' do
          post_request(now, params,
            signature: generate_signature(now, { 'not_the' => 'right params' })
          )

          expect(response).to_not be_successful
          expect(response.status).to eq(401)
        end

        it 'should fail with old timestamp' do
          old_timestamp = Time.now - 1.minute
          post_request(old_timestamp, params)

          expect(response).to_not be_successful
          expect(response.status).to eq(400)
        end
      end

      context 'slash command' do
        it 'should look up by class name and instantiate it correctly' do
          params = { "type" => 2, "bot" => { "data" => { "name" => "ping", "type" => 1 }, "type" => 2 } }

          post_request(now, params)

          expect(response).to be_successful

          # NOTE: Matches dummy/bot/ping_command.rb
          expect(JSON.parse(response.body)).to eq('type' => 4, 'data' => { 'content' => 'Pong!' })
        end

        it 'should look up by class name with multiple words and kebab case' do
          params = { "type" => 2, "bot" => { "data" => { "name" => "ping-pong", "type" => 1 }, "type" => 2 } }

          post_request(now, params)

          expect(response).to be_successful

          # NOTE: Matches dummy/bot/ping_pong_command.rb
          expect(JSON.parse(response.body)).to eq('type' => 4, 'data' => { 'content' => 'Ping pong!' })
        end
      end
    end
  end
end
