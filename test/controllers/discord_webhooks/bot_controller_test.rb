require "test_helper"

module DiscordWebhooks
  class BotControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def setup
      DiscordWebhooks.discord_public_key = signing_key.verify_key.to_bytes.unpack('H*').first
    end

    def teardown
      DiscordWebhooks.discord_public_key = nil
    end

    test "good ping" do
      now = Time.now

      Timecop.freeze(now) do
        post_request(now, { "type" => 1 })

        assert_response :success
        assert_equal({ 'type' => 1 }, response.parsed_body)
      end
    end

    test "bad signature" do
      now = Time.now

      Timecop.freeze(now) do
        post_request(now, { "type" => 1 },
          signature: generate_signature(now, { 'not_the' => 'right params' })
        )
      end

      assert_equal(response.status, 401)
    end

    test 'should fail with old timestamp' do
      now = Time.now
      old_timestamp = now - 1.minute

      Timecop.freeze(now) do
        post_request(old_timestamp, { "type" => 1 })
      end

      assert_equal(response.status, 400)
    end

    private

    def signing_key
      @signing_key ||= Ed25519::SigningKey.new(['0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'].pack('H*'))
    end

    def generate_signature(timestamp, params)
      signature_payload = timestamp.to_i.to_s + params.to_json
      signing_key.sign(signature_payload).unpack('H*').first
    end

    def post_request(timestamp, params, signature: nil)
      signature ||= generate_signature(timestamp, params)
      post bot_action_url, params: params, as: :json, headers: {
        "HTTP_X_SIGNATURE_TIMESTAMP" => timestamp.to_i,
        "HTTP_X_SIGNATURE_ED25519" => signature
      }
    end

    # around(:example) do |example|
    #   Timecop.freeze(now) do
    #     example.run
    #   end
    # end
    #
    # describe "POST /bot" do
    #   context 'discord ping' do
    #     let(:params) { { "type" => 1, 'guild_id' => 'fakeGuildId', "some_other" => "params" } }
    #
    #     it 'should handle a good ping' do
    #       post_request(now, params)
    #
    #       expect(response).to be_successful
    #       expect(JSON.parse(response.body)).to eq({ 'type' => 1 })
    #     end
    #
    #     it 'should fail with bad signature' do
    #       post_request(now, params,
    #         signature: generate_signature(now, { 'not_the' => 'right params' })
    #       )
    #
    #       expect(response).to_not be_successful
    #       expect(response.status).to eq(401)
    #     end
    #
    #     it 'should fail with old timestamp' do
    #       old_timestamp = Time.now - 1.minute
    #       post_request(old_timestamp, params)
    #
    #       expect(response).to_not be_successful
    #       expect(response.status).to eq(400)
    #     end
    # test "the truth" do
    #   assert true
    # end
  end
end
