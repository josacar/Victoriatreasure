require_relative './helpers/s3'
require_relative './helpers/kms'

module S3Secrets
  class Reader
    def initialize(s3_resource, s3_client, kms_client, kms_key_id)
      @kms_helper = S3Secrets::Helpers::Kms.new(kms_client, kms_key_id)
      @s3_helper = S3Secrets::Helpers::S3.new(s3_client, s3_resource)
    end

    def get_secret(file_uri, key)
      bucket = @s3_helper.bucket_from_file_uri(file_uri)
      file_path = @s3_helper.file_path_from_file_uri(file_uri)

      decrypted_json = get_json_secret_content(bucket, file_path)
      decrypted_json[key]
    end
    private

    def get_json_secret_content(bucket, file_path)
      downloaded_file = @s3_helper.download_file(bucket, file_path)

      @kms_helper.decrypt(downloaded_file)
    end
  end
end