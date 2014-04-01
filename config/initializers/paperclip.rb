

Paperclip::Attachment.default_options[:s3_host_name]=Rails.application.secrets.s3_endpoint if Rails.application.secrets.s3_endpoint