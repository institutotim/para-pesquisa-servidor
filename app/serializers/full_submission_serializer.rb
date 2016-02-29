class FullSubmissionSerializer < SubmissionSerializer
  has_many :log, serializer: FullLogSerializer
end
