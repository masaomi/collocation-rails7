json.extract! job, :id, :job_id, :status, :link, :created_at, :updated_at
json.url job_url(job, format: :json)
